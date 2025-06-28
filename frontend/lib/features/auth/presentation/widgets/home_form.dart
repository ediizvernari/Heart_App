import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/rounded_button.dart';

class HomeForm extends StatelessWidget {
  const HomeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.background.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundedButton(
                text: 'Log In',
                onPressed: () => Navigator.of(context).pushNamed('/login'),
              ),
              const SizedBox(height: 16),
              RoundedButton(
                text: 'User Sign Up',
                onPressed: () => Navigator.of(context).pushNamed('/signup_user'),
              ),
              const SizedBox(height: 16),
              RoundedButton(
                text: 'Medic Sign Up',
                onPressed: () => Navigator.of(context).pushNamed('/signup_medic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}