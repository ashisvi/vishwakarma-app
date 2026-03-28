import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import 'manual_donation_screen.dart';
import 'user_verification_screen.dart';
import 'location_entry_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: buildAppHeader(
        titleEn: 'Admin Panel',
        titleHi: 'व्यवस्थापक पैनल',
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            'Utility Features',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.maroon,
            ),
          ),
          Text(
            'उपयोगी सुविधाएँ',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.maroon.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Manual Donation',
            titleHi: 'ऑफलाइन दान',
            subtitle: 'Record cash donations manually.',
            subtitleHi: 'ऑफ़लाइन नकद दान दर्ज करें',
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
            title: 'User Verification',
            titleHi: 'उपयोगकर्ता सत्यापन',
            subtitle: 'Approve new members and assign roles.',
            subtitleHi: 'नए सदस्यों को स्वीकृत करें और भूमिकाएँ दें',
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
            title: 'Location Entry',
            titleHi: 'स्थान जोड़ें',
            subtitle: 'Add new States, Districts, Blocks, and Villages.',
            subtitleHi: 'नए राज्य, जिले, ब्लॉक और गाँव जोड़ें',
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
    required String titleHi,
    required String subtitle,
    required String subtitleHi,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
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
                      '$title / $titleHi',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors.subtitleGrey,
                      ),
                    ),
                    Text(
                      subtitleHi,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 12,
                        color: AppColors.subtitleGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.subtitleGrey),
            ],
          ),
        ),
      ),
    );
  }
}
