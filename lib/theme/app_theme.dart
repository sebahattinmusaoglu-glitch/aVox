import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background     = Color(0xFF0B0B18);
  static const Color surface        = Color(0xFF13132A);
  static const Color card           = Color(0xFF1A1A2E);
  static const Color primary        = Color(0xFFBDC2FF);
  static const Color secondary      = Color(0xFF4DD9C5);
  static const Color success        = Color(0xFF4CAF82);
  static const Color warning        = Color(0xFFFFB74D);
  static const Color danger         = Color(0xFFE53935);
  static const Color textPrimary    = Color(0xFFEEEEFF);
  static const Color textSecondary  = Color(0xFF8888AA);
  static const Color textMuted      = Color(0xFF555577);
  static const Color border         = Color(0xFF252545);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    ),
  );
}
