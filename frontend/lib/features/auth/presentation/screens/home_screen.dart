import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'login_screen.dart';
import 'signup_user_screen.dart';
import 'signup_medic_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Column(
        children: [
          const CustomAppBar(title: 'Welcome to the Health App!'),

          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RoundedButton(
                      text: 'Log In',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RoundedButton(
                      text: 'User Sign Up',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupUserScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RoundedButton(
                      text: 'Medic Sign Up',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupMedicScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
