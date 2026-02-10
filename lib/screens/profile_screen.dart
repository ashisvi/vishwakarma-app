import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.name = 'Rajesh Kumar',
    this.fatherName = 'Shyam Lal',
    this.designation = 'अध्यक्ष, युवा समिति',
    this.phone = '+91 98765 43210',
    this.village = 'Vishwakarma Nagar',
    this.block = 'Block A',
    this.district = 'Varanasi',
    this.photoFile,
  });

  final String name;
  final String fatherName;
  final String designation;
  final String phone;
  final String village;
  final String block;
  final String district;
  final File? photoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            color: AppColors.whiteCard,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildDetailsCard(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primarySaffron,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteCard.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.whiteCard,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: photoFile != null
                  ? Image.file(photoFile!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      size: 56,
                      color: AppColors.whiteCard,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteCard,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'पिता का नाम: $fatherName',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.whiteCard.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.whiteCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: AppColors.primarySaffron,
                ),
                const SizedBox(width: 6),
                Text(
                  designation,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
            _buildInfoRow(
              icon: Icons.phone,
              labelEn: 'Phone',
              labelHi: 'मोबाइल',
              value: phone,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.home_outlined,
              labelEn: 'Village',
              labelHi: 'गाँव',
              value: village,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.map_outlined,
              labelEn: 'Block',
              labelHi: 'ब्लॉक',
              value: block,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.location_city_outlined,
              labelEn: 'District',
              labelHi: 'जिला',
              value: district,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String labelEn,
    required String labelHi,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primarySaffron,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    labelEn,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.maroon,
                    ),
                  ),
                  Text(
                    ' / $labelHi',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 13,
                      color: AppColors.maroon.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.maroon.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _PrimaryActionButton(
          icon: Icons.edit_outlined,
          labelEn: 'Edit Profile',
          labelHi: 'प्रोफ़ाइल संपादित करें',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _SecondaryActionButton(
          icon: Icons.language,
          labelEn: 'Change Language',
          labelHi: 'भाषा बदलें',
          onTap: () {
            // TODO: Navigate to language selection
          },
        ),
        const SizedBox(height: 12),
        _TextActionButton(
          icon: Icons.logout,
          labelEn: 'Logout',
          labelHi: 'लॉगआउट',
          onTap: () {
            // TODO: Handle logout
          },
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labelEn,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelHi,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 20,
          color: AppColors.primarySaffron,
        ),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labelEn,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelHi,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primarySaffron),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: AppColors.maroon,
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: AppColors.maroon,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelEn,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            labelHi,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon,
            ),
          ),
        ],
      ),
    );
  }
}

