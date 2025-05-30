import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed      = Color(0xFF910000);
  static const Color primaryLight    = Color(0xFFB71C1C);
  static const Color primaryDark     = Color(0xFF600000);

  static const Color softGrey        = Color(0xFFE0E0E0);
  static const Color cardBackground  = Color(0xFFF9F9F9); // Light but warm background
  static const Color whiteOverlay    = Color.fromRGBO(255, 255, 255, 0.2);

  static const Color iconColor       = Color(0xFF5A5A5A);
  static const Color buttonText      = primaryRed;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primaryLight,
      AppColors.primaryRed,
      AppColors.primaryDark,
    ],
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primaryLight,
      AppColors.primaryRed,
    ],
  );

  static const Color accentGreen    = Color(0xFF2E7D32);
  static const Color accentYellow   = Color(0xFFFBC02D);
}
