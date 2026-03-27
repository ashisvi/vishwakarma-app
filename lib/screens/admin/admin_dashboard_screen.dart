import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'manual_donation_screen.dart';
import 'user_verification_screen.dart';
import 'location_entry_screen.dart';

import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Admin Panel',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'व्यवस्थापक पैनल',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Utility Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'NotoSansDevanagari',
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Manual Donation / ऑफलाइन दान',
            subtitle: 'Record cash donations manually.\n(ऑफ़लाइन नकद दान दर्ज करें)',
            icon: Icons.payments_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualDonationScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            title: 'User Verification / उपयोगकर्ता सत्यापन',
            subtitle: 'Approve new members and assign roles.\n(नए सदस्यों को स्वीकृत करें और भूमिकाएँ दें)',
            icon: Icons.verified_user_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserVerificationScreen()),
              );
            },
          ),
          _buildAdminCard(
            context,
            title: 'Location Entry / स्थान जोड़ें',
            subtitle: 'Add new States, Districts, Blocks, and Villages.\n(नए राज्य, जिले, ब्लॉक और गाँव जोड़ें)',
            icon: Icons.add_location_alt_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationEntryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySaffron.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primarySaffron, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
