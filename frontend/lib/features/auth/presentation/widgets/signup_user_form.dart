import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

class SignupUserForm extends StatefulWidget {
  const SignupUserForm({super.key});
  @override
  State<SignupUserForm> createState() => _SignupUserFormState();
}

class _SignupUserFormState extends State<SignupUserForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final userSignupRequestDto = UserSignupRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    final authController = context.read<AuthController>()
      ..email = userSignupRequestDto.email
      ..password = userSignupRequestDto.password;

    await authController.signupUser(
      context: context,
      userSignupDto: userSignupRequestDto,
      confirmPassword: _confirmPasswordController.text,
    );
  }

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
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  hintStyle: const TextStyle(color: AppColors.background),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  hintStyle: const TextStyle(color: AppColors.background),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: AppColors.background),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: AppColors.background),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: const TextStyle(color: AppColors.background),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 32),

              context.watch<AuthController>().isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.background),
                    )
                  : RoundedButton(
                      text: 'Sign Up',
                      onPressed: _handleSignup,
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.background,
                      borderRadius: 30,
                      elevation: 8,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}