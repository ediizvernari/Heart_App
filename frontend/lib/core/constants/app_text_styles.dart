import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle welcomeHeader = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle dialogContent = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle dialogButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryRed,
  );
}
