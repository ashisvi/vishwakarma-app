import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/donation_service.dart';
import 'cashfree_payment_screen.dart';

class DonationAmountScreen extends StatefulWidget {
  const DonationAmountScreen({super.key});

  @override
  State<DonationAmountScreen> createState() => _DonationAmountScreenState();
}

class _DonationAmountScreenState extends State<DonationAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isProcessing = false;

  static const List<int> _quickAmounts = [101, 501, 1100, 2100];

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  double get _parsedAmount {
    final text = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final canDonate = _parsedAmount > 0 && !_isProcessing;
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'दान राशि दर्ज करें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'Enter donation amount',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Extra bottom space to avoid overlap with the floating button.
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAmountBox(),
            const SizedBox(height: 24),
            _buildQuickButtons(),
            const SizedBox(height: 32),
            _buildCustomAmountField(),
            const SizedBox(height: 8),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canDonate ? _onProceed : null,
        backgroundColor: AppColors.primarySaffron,
        foregroundColor: AppColors.whiteCard,
        icon: const Icon(Icons.volunteer_activism),
        label: Text(
          'Donate / दान करें',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w800),
        ),
        isExtended: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAmountBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '₹ ${_parsedAmount.toStringAsFixed(2)}',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'आप कितनी दान राशि देना चाहते हैं?',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.maroon.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'How much would you like to donate?',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _quickAmounts.map((amt) {
        final isSelected = _parsedAmount == amt.toDouble();
        final foreground = isSelected ? AppColors.whiteCard : AppColors.maroon;
        final bg = isSelected ? AppColors.primarySaffron : AppColors.whiteCard;
        final sideColor =
            isSelected ? AppColors.primarySaffron : AppColors.primarySaffron.withValues(alpha: 0.35);

        return SizedBox(
          height: 48, // >=48dp tap target
          width: 120,
          child: FilledButton(
            onPressed: () {
              setState(() {
                _amountController.text = amt.toStringAsFixed(0);
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: foreground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: sideColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              '₹$amt',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom amount / अन्य राशि',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: GoogleFonts.notoSans(
              fontSize: 18,
              color: AppColors.maroon,
            ),
            hintText: 'Enter amount / राशि दर्ज करें',
            hintStyle: TextStyle(color: Colors.grey.shade700),
            filled: true,
            fillColor: AppColors.whiteCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.primarySaffron, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          style: GoogleFonts.notoSans(fontSize: 18, color: AppColors.maroon),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Text(
          'Donation Reason (Optional) / दान का कारण',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'E.g. Temple Construction / मंदिर निर्माण',
            hintStyle: TextStyle(color: Colors.grey.shade700),
            filled: true,
            fillColor: AppColors.whiteCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.primarySaffron, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          style: GoogleFonts.notoSans(fontSize: 16, color: AppColors.maroon),
        ),
      ],
    );
  }

  // Proceed UI is handled by the floating action button.

  Future<void> _onProceed() async {
    if (_parsedAmount <= 0) return;
    setState(() => _isProcessing = true);

    try {
      final intent = await createDonationIntent(_parsedAmount);
      if (intent == null || intent['id'] == null) {
        throw Exception('Unable to create donation intent');
      }

      final intentId = intent['id'] as String;
      final completed = await Navigator.of(context).push<bool?>(
        MaterialPageRoute(
          builder: (_) =>
              CashfreePaymentScreen(
                intentId: intentId, 
                amount: _parsedAmount,
                message: _messageController.text,
              ),
        ),
      );

      if (completed == true) {
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Donation failed: ${e.toString()}',
            style: GoogleFonts.notoSansDevanagari(fontSize: 14),
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
