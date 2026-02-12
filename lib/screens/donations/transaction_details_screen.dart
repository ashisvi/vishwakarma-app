import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.dateTimeLabel,
    required this.description,
    required this.upiReferenceId,
    required this.addedBy,
  });

  final double amount;
  final bool isCredit;
  final String status;
  final String dateTimeLabel;
  final String description;
  final String upiReferenceId;
  final String addedBy;

  @override
  Widget build(BuildContext context) {
    final amountColor = isCredit ? Colors.green.shade800 : Colors.red.shade800;
    final sign = isCredit ? '+' : '-';

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaction Details',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteCard,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(amountColor, sign),
            const SizedBox(height: 20),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color amountColor, String sign) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCredit ? 'Credit' : 'Debit',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateTimeLabel,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.maroon.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$sign₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.notoSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [_buildStatusChip()]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'pending':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      case 'failed':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'विवरण',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.maroon.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(labelEn: 'Description', value: description),
            const Divider(height: 24),
            _buildInfoRow(
              labelEn: 'UPI Reference ID',
              value: upiReferenceId,
              isMonospace: true,
            ),
            const Divider(height: 24),
            _buildInfoRow(labelEn: 'Added by', value: addedBy),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String labelEn,
    required String value,
    bool isMonospace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelEn,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              (isMonospace ? GoogleFonts.robotoMono() : GoogleFonts.notoSans())
                  .copyWith(
                    fontSize: 13,
                    color: AppColors.maroon.withValues(alpha: 0.9),
                  ),
        ),
      ],
    );
  }
}
