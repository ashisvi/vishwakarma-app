import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

enum AppLanguage { english, hindi }

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLanguage? _selectedLanguage;

  static const double _minTouchTargetHeight = 56.0;
  static const double _cardPadding = 20.0;
  static const double _cardBorderRadius = 20.0;
  static const double _selectedBorderWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLanguageCard(
                        language: AppLanguage.english,
                        label: 'English',
                        icon: Icons.language,
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageCard(
                        language: AppLanguage.hindi,
                        label: 'हिन्दी',
                        icon: Icons.translate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildContinueButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.goldAccent.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.handyman,
          size: 44,
          color: AppColors.primarySaffron,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Select Language',
          style: GoogleFonts.notoSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'भाषा चुनें',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required AppLanguage language,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedLanguage == language;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedLanguage = language),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTouchTargetHeight * 2),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_cardPadding),
            decoration: BoxDecoration(
              color: AppColors.whiteCard,
              borderRadius: BorderRadius.circular(_cardBorderRadius),
              border: Border.all(
                color: isSelected
                    ? AppColors.primarySaffron
                    : AppColors.creamBackground,
                width: isSelected ? _selectedBorderWidth : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySaffron.withValues(alpha: 0.12)
                        : AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? AppColors.primarySaffron
                        : AppColors.maroon.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: label == 'हिन्दी'
                        ? GoogleFonts.notoSansDevanagari(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          )
                        : GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primarySaffron,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedLanguage != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: canContinue ? _onContinue : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          disabledBackgroundColor: AppColors.primarySaffron.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Continue'),
      ),
    );
  }

  void _onContinue() {
    if (_selectedLanguage == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
