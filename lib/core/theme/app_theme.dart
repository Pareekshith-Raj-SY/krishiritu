import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const forestGreen = Color(0xFF1B5E20);
  static const leafGreen = Color(0xFF388E3C);
  static const lightGreen = Color(0xFF66BB6A);
  static const paleGreen = Color(0xFFE8F5E9);
  static const cream = Color(0xFFFFFDE7);
  static const warmAmber = Color(0xFFFF8F00);
  static const earthBrown = Color(0xFF795548);
  static const skyBlue = Color(0xFF0288D1);
  static const errorRed = Color(0xFFD32F2F);
  static const textDark = Color(0xFF1A1A1A);
  static const textMedium = Color(0xFF555555);
  static const textLight = Color(0xFF888888);
  static const cardBg = Color(0xFFFFFFFF);
  static const scaffoldBg = Color(0xFFF5F7F5);
  static const divider = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.leafGreen,
        primary: AppColors.leafGreen,
        secondary: AppColors.warmAmber,
        surface: AppColors.cardBg,
        error: AppColors.errorRed,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textDark),
        displayMedium: GoogleFonts.nunito(
          fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMedium),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cardBg),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.leafGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.leafGreen,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.leafGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.leafGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.nunito(color: AppColors.textMedium),
        hintStyle: GoogleFonts.nunito(color: AppColors.textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.leafGreen,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paleGreen,
        labelStyle: GoogleFonts.nunito(
            fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.leafGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
