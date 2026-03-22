import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';

class UpiSelectionScreen extends StatefulWidget {
  const UpiSelectionScreen({
    super.key,
    required this.intentId,
    required this.amount,
  });

  final String intentId;
  final double amount;

  @override
  State<UpiSelectionScreen> createState() => _UpiSelectionScreenState();
}

class _UpiSelectionScreenState extends State<UpiSelectionScreen> {
  List<ApplicationMeta>? _availableApps;
  String? _selectedApp;
  bool _isLoading = true;
  bool _isProcessing = false;

  static final String _receiverUpiId = dotenv.env['RECEIVER_UPI_ID'] ?? '';
  static final String _receiverName =
      dotenv.env['RECEIVER_NAME'] ?? 'Vishwakarma Yuva Sangathan';

  @override
  void initState() {
    super.initState();
    _loadUpiApps();
  }

  Future<void> _loadUpiApps() async {
    try {
      final apps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
      debugPrint('Found ${apps.length} UPI apps');

      setState(() {
        _availableApps = apps;
      });
    } catch (e) {
      debugPrint('Failed to load UPI apps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to detect UPI apps. Please install one.'),
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primarySaffron,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detecting UPI apps...',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we check for installed UPI applications.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.maroon.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_availableApps == null || _availableApps!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: AppColors.maroon.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              Platform.isIOS
                  ? 'UPI Not Available on iOS'
                  : 'No UPI apps available',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Platform.isIOS
                  ? 'UPI payments are currently only supported on Android devices. Please use an Android device to make donations.'
                  : 'Please install a UPI app like Google Pay, PhonePe, or Paytm to continue with the donation.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.maroon.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!Platform.isIOS)
              ElevatedButton(
                onPressed: () => setState(() {
                  _isLoading = true;
                  _loadUpiApps();
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySaffron,
                  foregroundColor: AppColors.whiteCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry Detection',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
          _availableApps = null;
          _selectedApp = null;
        });
        await _loadUpiApps();
      },
      child: ListView.separated(
        itemCount: _availableApps!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appMeta = _availableApps![index];
          final selected =
              _selectedApp == appMeta.upiApplication.androidPackageName;
          return _buildAppCard(appMeta, selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'UPI ऐप चुनें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'Choose UPI app',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            const SizedBox(height: 16),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(ApplicationMeta appMeta, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(
        () => _selectedApp = appMeta.upiApplication.androidPackageName,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primarySaffron
                : AppColors.primarySaffron.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAppLogo(appMeta),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                appMeta.upiApplication.appName,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primarySaffron),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo(ApplicationMeta appMeta) {
    final appId = appMeta.upiApplication.androidPackageName.toLowerCase();
    Color bg = AppColors.primarySaffron;

    if (appId.contains('googlepay') || appId.contains('gpay')) {
      bg = Colors.blue.shade600;
    } else if (appId.contains('phonepe')) {
      bg = Colors.purple.shade600;
    } else if (appId.contains('paytm')) {
      bg = Colors.lightBlue.shade600;
    } else if (appId.contains('bhim')) {
      bg = Colors.green.shade700;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: bg,
      child: appMeta.upiApplication.appName.isNotEmpty
          ? Text(
              appMeta.upiApplication.appName[0],
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            )
          : const Icon(Icons.payment, color: Colors.white),
    );
  }

  Widget _buildPayButton() {
    final canPay = _selectedApp != null && !_isProcessing;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: canPay ? _onPayNow : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          disabledBackgroundColor: AppColors.primarySaffron.withValues(
            alpha: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pay Now'),
                  const SizedBox(width: 8),
                  Text(
                    'अभी भुगतान करें',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onPayNow() async {
    if (_selectedApp == null || _availableApps == null) return;

    final appMeta = _availableApps!.firstWhere(
      (app) => app.upiApplication.androidPackageName == _selectedApp,
      orElse: () => _availableApps!.first,
    );

    setState(() => _isProcessing = true);
    try {
      final transactionRefId =
          'donation_${DateTime.now().millisecondsSinceEpoch}';

      final response = await UpiPay.initiateTransaction(
        app: appMeta.upiApplication,
        receiverUpiAddress: _receiverUpiId,
        receiverName: _receiverName,
        transactionRef: transactionRefId,
        amount: widget.amount.toStringAsFixed(2),
        transactionNote: 'Donation',
      );

      final isSuccessful =
          response.status == UpiTransactionStatus.success ||
          response.status == UpiTransactionStatus.submitted ||
          response.status == UpiTransactionStatus.launched;

      final upiRef = response.txnRef ?? response.txnId ?? transactionRefId;

      if (isSuccessful) {
        final success = await markIntentSuccess(widget.intentId, upiRef);
        if (!success) {
          throw Exception('Failed to mark intent success');
        }
        await createTransaction(widget.amount, upiRef);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Donation successful!')));
        Navigator.of(context).pop(true);
      } else {
        await markIntentFailed(widget.intentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Donation failed: ${response.status}')),
          );
        }
      }
    } catch (e) {
      await markIntentFailed(widget.intentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
