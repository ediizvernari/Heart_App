import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';

class SignupUserScreen extends StatefulWidget {
  const SignupUserScreen({Key? key}) : super(key: key);

  @override
  State<SignupUserScreen> createState() => _SignupUserScreenState();
}

class _SignupUserScreenState extends State<SignupUserScreen> {
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
    final userSignupDto = UserSignupRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    final authController = context.read<AuthController>()
      ..email = userSignupDto.email
      ..password = userSignupDto.password;

    await authController.signupUser(
      context: context,
      userSignupDto: userSignupDto,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();

    if (authCtrl.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(authCtrl.error!),
            actions: [
              TextButton(
                onPressed: () {
                  authCtrl.clearError();
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
        child: Column(
          children: [
            const CustomAppBar(title: 'Create a user account'),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FractionallySizedBox(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.whiteOverlay,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _firstNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _lastNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          authCtrl.isLoading
                              ? const CircularProgressIndicator()
                              : RoundedButton(
                                  text: 'Sign Up',
                                  onPressed: _handleSignup,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
