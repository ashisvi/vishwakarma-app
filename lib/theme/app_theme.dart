import 'package:flutter/material.dart';

/// Cultural, trust-building color palette for the Indian community app.
class AppColors {
  AppColors._();

  /// Softer, eye-friendly orange for primary actions and highlights.
  static const Color primarySaffron = Color(0xFFFFB347); // #FFB347

  /// Dark maroon for readable text and secondary UI.
  static const Color maroon = Color(0xFF8B3A3A); // #8B3A3A

  /// Warm accent used for outlines/badges (kept softer than pure gold).
  static const Color goldAccent = Color(0xFFFFC46B);

  /// Dislike reaction uses a neutral grey for elder-friendly contrast.
  static const Color dislikeGrey = Color(0xFFB0B0B0);

  /// Soft cream background for elder-friendly contrast.
  static const Color creamBackground = Color(0xFFFFF8F0); // #FFF8F0

  static const Color whiteCard = Color(0xFFFFFFFF);

  static const Color authorizedGreen = Color(0xFF2E7D32);

  /// Neutral grey for subtitles and secondary labels.
  static const Color subtitleGrey = Color(0xFF757575);

  // ─── Standard border radii ───
  static const double radiusCard = 16.0;
  static const double radiusCardLarge = 20.0;
  static const double radiusInput = 14.0;
}
