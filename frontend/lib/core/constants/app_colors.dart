import 'package:flutter/material.dart';

class AppColors {
  
  static const Color primaryLight = Color(0xFF90CAF9);
  static const Color primaryBlue = Color.fromARGB(255, 120, 169, 238);
  static const Color primaryDark  = Color(0xFF1976D2);

  static const Color accentOrange = Color(0xFFFFA726);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color whiteOverlay = Color.fromRGBO(255, 255, 255, 0.2);

  static const Color iconColor = Color(0xFF5A5A5A);
  static const Color buttonText = primaryBlue;

  static const Color errorRed = Color(0xFFF44336);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryLight, 
      primaryBlue,
      primaryDark,
    ],
    stops: [0.6, 1.0, 1.0],
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryLight, primaryBlue],
    stops: [0.0, 1.0],
  );
}
