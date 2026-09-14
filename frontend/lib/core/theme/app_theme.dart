import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.yellow,
        onPrimary: AppColors.black,
        secondary: AppColors.yellowMuted,
        surface: AppColors.blackSurface,
        onSurface: AppColors.yellow,
        error: AppColors.errorRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.yellow,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          color: AppColors.yellow,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          fontSize: 18,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.orbitron(
          color: AppColors.yellow,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
        bodyMedium: GoogleFonts.jetBrainsMono(color: AppColors.yellow),
        bodyLarge: GoogleFonts.jetBrainsMono(color: AppColors.yellow),
        labelMedium: GoogleFonts.jetBrainsMono(
          color: AppColors.yellowMuted,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blackSurface,
        labelStyle: const TextStyle(color: AppColors.yellowMuted),
        floatingLabelStyle: const TextStyle(color: AppColors.yellow),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.yellowMuted),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.yellowMuted),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.yellow, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.errorRed, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.yellowMuted),
      ),
      iconTheme: const IconThemeData(color: AppColors.yellow),
      dividerColor: AppColors.yellowMuted,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.blackElevated,
        contentTextStyle: TextStyle(color: AppColors.yellow),
        actionTextColor: AppColors.yellow,
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.yellowLight,
        onPrimary: AppColors.black,
        secondary: AppColors.darkText,
        surface: Colors.white,
        onSurface: AppColors.darkText,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F1EE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.darkText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.yellowLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkText,
          foregroundColor: AppColors.yellowLight,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
