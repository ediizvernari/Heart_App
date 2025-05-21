import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/widgets/curved_header.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(authController.error!),
            actions: [
              TextButton(
                onPressed: () {
                  authController.clearError();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const CurvedHeader(
                title: 'Login to Your Account',
                showBack: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.start,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => authController.email = v,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) => authController.password = v,
                    ),

                    const SizedBox(height: 24),

                    authController.isLoading
                        ? const CircularProgressIndicator()
                        : RoundedButton(
                            text: 'Login',
                            onPressed: () {
                              authController.login(context: context);
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}