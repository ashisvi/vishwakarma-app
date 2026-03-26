import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';

import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';

import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';

class CashfreePaymentScreen extends StatefulWidget {
  const CashfreePaymentScreen({
    super.key,
    required this.intentId,
    required this.amount,
    this.message,
  });

  final String intentId;
  final double amount;
  final String? message;

  @override
  State<CashfreePaymentScreen> createState() => _CashfreePaymentScreenState();
}

class _CashfreePaymentScreenState extends State<CashfreePaymentScreen> {
  final CFPaymentGatewayService _cfPaymentGatewayService =
      CFPaymentGatewayService();
  bool _isProcessing = true;
  String _statusMessage = 'Initializing Cashfree...';

  @override
  void initState() {
    super.initState();
    _cfPaymentGatewayService.setCallback(verifyPayment, onError);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCashfreeFlow();
    });
  }

  @override
  void dispose() {
    // Clear callback on dispose although flutter_cashfree_pg_sdk doesn't
    // explicitly demand it unless we are registering it again.
    super.dispose();
  }

  Future<void> _startCashfreeFlow() async {
    setState(() {
      _statusMessage = 'Creating order...';
    });

    try {
      debugPrint('==== CASHFREE FLOW DEBUG ====');
      debugPrint('Starting Cashfree API call...');
      final cashfreeKey = dotenv.env['CASHFREE_KEY']?.trim() ?? '';
      final cashfreeSecret = dotenv.env['CASHFREE_SECRET_KEY']?.trim() ?? '';

      if (cashfreeKey.isEmpty || cashfreeSecret.isEmpty) {
        debugPrint('ERROR: Cashfree keys are missing or empty in .env');
        throw Exception('Cashfree keys not configured in .env');
      }

      final orderId = 'don_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('Generated Order ID: $orderId');

      // Determine sandbox vs prod based on key prefix (usually test_ or similar, here we default to SANDBOX for test keys)
      final isSandbox = cashfreeKey.toLowerCase().contains('test');
      final baseUrl = isSandbox
          ? 'https://sandbox.cashfree.com/pg/orders'
          : 'https://api.cashfree.com/pg/orders';
      debugPrint('Is Sandbox Mode: $isSandbox');
      debugPrint('Base URL: $baseUrl');

      var body = jsonEncode({
        "order_amount": widget.amount,
        "order_currency": "INR",
        "order_id": orderId,
        "customer_details": {
          "customer_id": "cust_${DateTime.now().millisecondsSinceEpoch}",
          "customer_phone": "9999999999", // Required generic fallback
          "customer_name": dotenv.env['RECEIVER_NAME'] ?? "Donator",
          "customer_email": "donator@vishwakarma.example",
        },
        "order_meta": {
          "return_url": "https://bounteous.io/return?order_id={order_id}",
        },
      });
      debugPrint('Request Payload: $body');

      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'x-client-id': cashfreeKey,
          'x-client-secret': cashfreeSecret,
          'x-api-version': '2023-08-01',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        String paymentSessionId = data['payment_session_id'];
        debugPrint(
          'Successfully extracted paymentSessionId: $paymentSessionId',
        );

        setState(() {
          _statusMessage = 'Opening Checkout...';
        });

        // Initiate checkout
        var session = CFSessionBuilder()
            .setEnvironment(
              isSandbox ? CFEnvironment.SANDBOX : CFEnvironment.PRODUCTION,
            )
            .setOrderId(orderId)
            .setPaymentSessionId(paymentSessionId)
            .build();

        var theme = CFThemeBuilder()
            .setPrimaryFont("Inter")
            .setPrimaryTextColor("#721c24") // AppColors.maroon equivalent
            .build();

        var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
            .setSession(session)
            .setTheme(theme)
            .build();

        debugPrint('Dispatching to CFPaymentGatewayService...');
        _cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
      } else {
        debugPrint('ERROR: Non-200 status code received');
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      debugPrint('Cashfree Order Error: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error starting payment';
          _isProcessing = false;
        });
      }
      await markIntentFailed(widget.intentId);
    }
  }

  void verifyPayment(String orderId) async {
    debugPrint('==== CASHFREE VERIFY PAYMENT CALLBACK ====');
    debugPrint('verifyPayment called for orderId: $orderId');
    if (mounted) {
      setState(() {
        _statusMessage = 'Verifying payment status...';
        _isProcessing = true;
      });
    }

    try {
      final cashfreeKey = dotenv.env['CASHFREE_KEY']?.trim() ?? '';
      final cashfreeSecret = dotenv.env['CASHFREE_SECRET_KEY']?.trim() ?? '';
      final isSandbox = cashfreeKey.toLowerCase().contains('test');
      final baseUrl = isSandbox
          ? 'https://sandbox.cashfree.com/pg/orders'
          : 'https://api.cashfree.com/pg/orders';

      var response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'x-client-id': cashfreeKey,
          'x-client-secret': cashfreeSecret,
          'x-api-version': '2023-08-01',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String orderStatus = data['order_status'];
        debugPrint('Got Cashfree Order Status: $orderStatus');

        if (orderStatus == 'PAID') {
          final success = await markIntentSuccess(widget.intentId, orderId);
          if (!success) {
            throw Exception('Failed to update database intent');
          }
          await createTransaction(
            widget.amount,
            orderId,
            description: widget.message,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation successful!'),
              backgroundColor: AppColors.authorizedGreen,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          // ACTIVE usually means pending or user abandoned
          await markIntentFailed(widget.intentId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment not completed. Status: $orderStatus'),
            ),
          );
          Navigator.of(context).pop(false);
        }
      } else {
        throw Exception('Failed to fetch order status from Cashfree');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error validating transaction: $e')),
      );
      Navigator.of(context).pop(false);
    }
  }

  void onError(CFErrorResponse errorResponse, String orderId) async {
    debugPrint('==== CASHFREE ON ERROR CALLBACK ====');
    debugPrint('onError called for orderId: $orderId');
    final message = errorResponse.getMessage() ?? 'Unknown Error';
    debugPrint('Cashfree error message: $message');
    debugPrint('Cashfree error code: ${errorResponse.getCode()}');

    if (mounted) {
      setState(() {
        _statusMessage = 'Payment failed: $message';
        _isProcessing = false;
      });
    }

    await markIntentFailed(widget.intentId);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment failed: $message')));
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Processing Payment'),
        backgroundColor: AppColors.primarySaffron,
        foregroundColor: AppColors.whiteCard,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
              const CircularProgressIndicator(color: AppColors.primarySaffron),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16, color: AppColors.maroon),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
