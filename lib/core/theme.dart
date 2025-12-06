// lib/core/theme.dart - Material 3 ColorScheme (Minimal Required Fields)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    // REQUIRED FIELDS ONLY (9 total)
    brightness: Brightness.light,
    primary: AppColors.primary, // #6366F1
    onPrimary: Colors.white, // Text on primary
    secondary: AppColors.primaryDark, // #4F46E5
    onSecondary: Colors.white, // Text on secondary
    error: AppColors.error, // #EF4444
    onError: Colors.white, // Text on error
    surface: AppColors.surfaceLight, // #F8FAFC
    onSurface: AppColors.textPrimary, // #1E293B - Text on surface
  ),
  scaffoldBackgroundColor: AppColors.surfaceLight,
  textTheme: _createPoppinsTextTheme(Brightness.light),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    // REQUIRED FIELDS ONLY (9 total)
    brightness: Brightness.dark,
    primary: AppColors.primary, // #6366F1
    onPrimary: Colors.black, // Text on primary (dark contrast)
    secondary: AppColors.primaryDark, // #4F46E5
    onSecondary: Colors.white, // Text on secondary
    error: AppColors.error, // #EF4444
    onError: Colors.white, // Text on error
    surface: AppColors.surfaceDark, // #0F172A
    onSurface: Colors.white, // White text on dark surface
  ),
  scaffoldBackgroundColor: AppColors.surfaceDark,
  textTheme: _createPoppinsTextTheme(Brightness.dark),
  useMaterial3: true,
);

TextTheme _createPoppinsTextTheme(Brightness brightness) {
  return GoogleFonts.poppinsTextTheme()
      .copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16),
        bodyMedium: GoogleFonts.poppins(fontSize: 14),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      )
      .apply(
        bodyColor: brightness == Brightness.light
            ? AppColors.textPrimary
            : Colors.white,
      );
}
