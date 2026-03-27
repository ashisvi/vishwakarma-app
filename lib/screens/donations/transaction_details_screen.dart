import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../members/user_profile_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final double amount;
  final bool isCredit;
  final String status;
  final String dateTimeLabel;
  final String description;
  final String paymentReferenceId;
  final String addedBy;
  final Map<String, dynamic>? userData;

  const TransactionDetailsScreen({
    super.key,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.dateTimeLabel,
    required this.description,
    required this.paymentReferenceId,
    required this.addedBy,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteCard),
        title: Column(
          children: [
            Text(
              'Transaction Details',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'लेन-देन का विवरण',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeader(statusColor, statusIcon),
            const SizedBox(height: 24),
            _buildAmountCard(),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 48),
        ),
        const SizedBox(height: 12),
        Text(
          status.toUpperCase(),
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateTimeLabel,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.maroon.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isCredit ? 'DEPOSITED AMOUNT / जमा राशि' : 'WITHDRAWAL AMOUNT / निकासी राशि',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.maroon.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.notoSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(
            Icons.description_outlined,
            'Description / विवरण',
            description.isEmpty ? 'N/A' : description,
          ),
          const Divider(height: 32),
          _buildDetailItem(
            Icons.receipt_long_outlined,
            'Reference ID / संदर्भ आईडी',
            paymentReferenceId.isEmpty ? 'N/A' : paymentReferenceId,
          ),
          const Divider(height: 32),
          _buildDonorItem(context),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primarySaffron),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonorItem(BuildContext context) {
    final donorName = userData?['name'] as String? ?? 'N/A';
    final village = userData?['village'] as String? ?? '';
    final district = userData?['district'] as String? ?? '';
    
    String subInfo = 'N/A';
    if (village.isNotEmpty || district.isNotEmpty) {
       subInfo = [village, district].where((s) => s.isNotEmpty).join(', ');
    } else if (userData == null && addedBy.isNotEmpty) {
       subInfo = 'ID: $addedBy';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_outline, size: 22, color: AppColors.primarySaffron),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Added By / द्वारा जोड़ा गया',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                donorName,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
              if (subInfo.isNotEmpty)
                Text(
                  subInfo,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    color: AppColors.maroon.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (userData != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(user: userData!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    'View Profile / प्रोफाइल देखें',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primarySaffron,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
      case 'dropped':
        return Colors.red.shade700;
      default:
        return AppColors.maroon;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.access_time;
      case 'failed':
      case 'dropped':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }
}
