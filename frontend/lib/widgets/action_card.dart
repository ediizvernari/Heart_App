import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  /// [isPrimary] determines styling for the primary (larger) action.
  const ActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = isPrimary ? AppColors.primaryRed : Colors.grey[700]!;
    final textColor = isPrimary ? AppColors.primaryRed : Colors.black;
    final iconSize = isPrimary ? 64.0 : 48.0;
    final fontSize = isPrimary ? 18.0 : 14.0;

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}