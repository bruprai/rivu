import 'package:extra/core/colors.dart';
import 'package:extra/core/gradients.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> accounts = [
    'Main Checking',
    'Cash',
    'Credit Card',
    'Savings',
  ];

  static const List<String> categories = [
    'Groceries',
    'Rent',
    'Salary',
    'Fun',
    'Transport',
    'Utilities',
    'Entertainment',
  ];

  static const double defaultAmount = 0.0;
  static const int defaultMaxLines = 1;
  static const Duration formAnimationDuration = Duration(milliseconds: 400);

  static const double glassBlurSigma = 20.0;
  static const double glassBorderWidth = 1.5;
  static const double receiptThumbnailHeight = 100.0;
  static const double dropdownMenuMaxHeight = 200.0;

  static const String receiptBucket = 'receipts';
  static const String receiptFileExt = 'jpg';
  static const String amountRequired = 'Enter amount';
  static const String amountInvalid = 'Enter valid number';

  static LinearGradient bodyGradientForCategory(String category) =>
      CategoryGradients.bodyGradient(category);

  static LinearGradient headerGradientForCategory(String category) =>
      CategoryGradients.headerGradient(category);

  static Color colorForCategory(String category) {
    switch (category) {
      case 'Groceries':
      case 'Salary':
        return AppColors.success;
      case 'Rent':
        return AppColors.error;
      case 'Fun':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}
