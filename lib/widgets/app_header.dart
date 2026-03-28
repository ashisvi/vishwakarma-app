import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Builds a consistent dual-language AppBar used across every screen.
///
/// Standard pattern:
/// - English title on top (18sp, w700)
/// - Hindi subtitle below (13sp, w700, 90% opacity)
/// - Saffron background, white text, centered
PreferredSizeWidget buildAppHeader({
  required String titleEn,
  required String titleHi,
  PreferredSizeWidget? bottom,
  List<Widget>? actions,
  bool showBackButton = true,
}) {
  return AppBar(
    centerTitle: true,
    backgroundColor: AppColors.primarySaffron,
    elevation: 0,
    iconTheme: const IconThemeData(color: AppColors.whiteCard),
    automaticallyImplyLeading: showBackButton,
    title: Column(
      children: [
        Text(
          titleEn,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteCard,
          ),
        ),
        Text(
          titleHi,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteCard.withValues(alpha: 0.9),
          ),
        ),
      ],
    ),
    bottom: bottom,
    actions: actions,
  );
}
