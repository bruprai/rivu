import 'package:flutter/material.dart';

// final Color primaryColor = Color(0xFF6366F1); // Indigo
// final Color primaryDarkColor = Color(0xFF4F46E5);
// final Color successColor = Color(0xFF10B981); // Emerald
// final Color warningColor = Color(0xFFF59E0B); // Amber
// final Color errorColor = Color(0xFFEF4444); // Red
// final Color surfaceColor = Color(0xFFF8FAFC); // Slate 50
// final Color glassColor = Color.fromRGBO(255, 255, 255, 0.25);
// final Color darkModeBackground = Color(0xFF0F172A); // Slate 900

// const LinearGradient primaryGradient = LinearGradient(
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
// );

class AppColors {
  // Primary Colors
  static const Color primary = Color(
    0xFF6366F1,
  ); // Indigo - Trust + Intelligence
  static const Color primaryDark = Color(0xFF4F46E5); // Primary Dark

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald - Money in
  static const Color warning = Color(0xFFF59E0B); // Amber - Close to budget
  static const Color error = Color(0xFFEF4444); // Red - Over budget

  // Backgrounds
  static const Color surfaceLight = Color(
    0xFFF8FAFC,
  ); // Slate 50 - Clean backgrounds
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900 - Dark Mode
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // Slate 800 - Main text (light mode)
  static const Color textSecondary = Color(
    0xFF64748B,
  ); // Slate 500 - Secondary text
  // Glassmorphism
  static const Color glassLight = Color.fromRGBO(255, 255, 255, 0.25);
  static const Color glassDark = Color.fromRGBO(30, 41, 59, 0.8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
}
