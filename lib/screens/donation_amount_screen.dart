import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class DonationAmountScreen extends StatefulWidget {
  const DonationAmountScreen({super.key});

  @override
  State<DonationAmountScreen> createState() => _DonationAmountScreenState();
}

class _DonationAmountScreenState extends State<DonationAmountScreen> {
  final TextEditingController _amountController = TextEditingController();

  static const List<int> _quickAmounts = [101, 501, 1100, 2100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _parsedAmount {
    final text = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'दान राशि दर्ज करें',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteCard,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAmountBox(),
            const SizedBox(height: 24),
            _buildQuickButtons(),
            const SizedBox(height: 32),
            _buildCustomAmountField(),
            const SizedBox(height: 40),
            _buildProceedButton(),
          ],
        ),
      ),
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
              color: AppColors.maroon.withValues(alpha: 0.8),
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
        return ChoiceChip(
          label: Text(
            '₹$amt',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.primarySaffron,
          backgroundColor: AppColors.whiteCard,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.whiteCard : AppColors.maroon,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primarySaffron
                  : AppColors.primarySaffron.withValues(alpha: 0.4),
            ),
          ),
          onSelected: (_) {
            setState(() {
              _amountController.text = amt.toStringAsFixed(0);
            });
          },
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
              fontSize: 16,
              color: AppColors.maroon,
            ),
            hintText: 'Enter amount',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),
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
              vertical: 14,
            ),
          ),
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: AppColors.maroon,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    final canProceed = _parsedAmount > 0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: canProceed ? _onProceed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          disabledBackgroundColor:
              AppColors.primarySaffron.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Proceed to Pay'),
            const SizedBox(width: 8),
            Text(
              'भुगतान जारी रखें',
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

  void _onProceed() {
    if (_parsedAmount <= 0) return;
    // TODO: Navigate to UPI selection / payment flow with _parsedAmount
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹${_parsedAmount.toStringAsFixed(2)} के लिए भुगतान प्रक्रिया शुरू होगी',
          style: GoogleFonts.notoSansDevanagari(fontSize: 14),
        ),
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

