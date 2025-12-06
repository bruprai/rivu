// lib/core/gradients.dart - COMPACT PROGRAMMATIC GRADIENTS
import 'package:flutter/material.dart';
import 'colors.dart';

class CategoryGradients {
  // ✅ Base colors mapped to categories
  static const Map<String, Color> _categoryColors = {
    'Groceries': Color(0xFF10B981), // Emerald
    'Rent': Color(0xFFEF4444), // Red
    'Salary': Color(0xFF06B6D4), // Cyan
    'Fun': Color(0xFFF59E0B), // Amber
  };

  // ✅ Generate BODY gradient (4 subtle colors)
  static LinearGradient bodyGradient(String category) {
    final baseColor = _categoryColors[category] ?? AppColors.primary;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.4),
        baseColor.withOpacity(0.1),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
  }

  // ✅ Generate HEADER gradient (2 bold colors)
  static LinearGradient headerGradient(String category) {
    final baseColor = _categoryColors[category] ?? AppColors.primary;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor.withOpacity(0.9).withBlue(baseColor.blue - 30),
        baseColor,
      ],
    );
  }

  // ✅ Default fallback
  static const LinearGradient defaultBody = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
  );
  static const LinearGradient defaultHeader = AppColors.primaryGradient;
}
