import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_upi_intent/flutter_upi_intent.dart';

import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';

class UpiPaymentScreen extends StatefulWidget {
  const UpiPaymentScreen({
    super.key,
    required this.intentId,
    required this.amount,
    this.message,
  });

  final String intentId;
  final double amount;
  final String? message;

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  List<UpiApp>? _installedApps;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await UpiIntent.getInstalledApps();
      if (mounted) {
        setState(() {
          _installedApps = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load UPI apps: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePayment(UpiApp? app) async {
    if (_isProcessingPayment) return;

    final upiId = dotenv.env['UPI_ID']?.trim() ?? 'sample@upi';
    final payeeName = dotenv.env['PAYEE_NAME']?.trim() ?? 'Vishwakarma Yuva Sangathan';

    final payment = UpiPayment(
      payeeVpa: upiId,
      payeeName: payeeName,
      amount: widget.amount.toStringAsFixed(2),
      transactionRef: widget.intentId,
      transactionNote: widget.message ?? 'Donation to Vishwakarma Yuva Sangathan',
    );

    setState(() => _isProcessingPayment = true);

    try {
      final response = await UpiIntent.launch(payment, app: app);
      
      if (!mounted) return;

      switch (response.status) {
        case UpiStatus.success:
          await _onSuccess(response.transactionRef ?? widget.intentId);
          break;
        case UpiStatus.submitted:
          // Handle as pending
          _showStatusSnackBar('Payment Submitted (Pending). Checking status...', isWarning: true);
          // For simplicity in this version, we will treat SUBMITTED as potentially successful 
          // but you should verify server-side.
          await _onSuccess(response.transactionRef ?? widget.intentId);
          break;
        case UpiStatus.userCancelled:
          _showStatusSnackBar('Payment cancelled by user');
          await markIntentFailed(widget.intentId);
          break;
        case UpiStatus.failure:
          _showStatusSnackBar('Payment failed: ${response.rawResponse ?? "Unknown error"}');
          await markIntentFailed(widget.intentId);
          break;
        default:
          _showStatusSnackBar('Unknown result: ${response.rawResponse}');
      }
    } catch (e) {
      _showStatusSnackBar('Launch Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _onSuccess(String ref) async {
    final success = await markIntentSuccess(widget.intentId, ref);
    if (success) {
      await createTransaction(
        widget.amount,
        ref,
        description: widget.message,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation successful! / दान सफल रहा!'),
            backgroundColor: AppColors.authorizedGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      _showStatusSnackBar('Failed to update status in server');
    }
  }

  void _showStatusSnackBar(String message, {bool isWarning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? Colors.orange : AppColors.maroon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          'Choose Payment App',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primarySaffron,
        foregroundColor: AppColors.whiteCard,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primarySaffron))
          : _errorMessage != null
              ? _buildErrorView()
              : _isProcessingPayment
                  ? _buildProcessingView()
                  : _buildAppGrid(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.maroon),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: AppColors.maroon)),
          TextButton(onPressed: _loadApps, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primarySaffron),
          const SizedBox(height: 24),
          Text(
            'Processing your payment...',
            style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not close the app / कृपया ऐप बंद न करें',
            style: GoogleFonts.notoSansDevanagari(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid() {
    final apps = _installedApps ?? [];
    
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                'No UPI Apps Found',
                style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Please install GPay, PhonePe, or BHIM to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _handlePayment(null),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Try System Chooser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySaffron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installed Apps',
            style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.maroon),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return InkWell(
                  onTap: () => _handlePayment(app),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: app.iconBase64 != null
                            ? Image.memory(
                                base64Decode(app.iconBase64!),
                                width: 48,
                                height: 48,
                              )
                            : const Icon(Icons.apps, size: 48, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => _handlePayment(null),
              icon: const Icon(Icons.more_horiz),
              label: const Text('Show More Options'),
              style: TextButton.styleFrom(foregroundColor: AppColors.maroon),
            ),
          ),
        ],
      ),
    );
  }
}
