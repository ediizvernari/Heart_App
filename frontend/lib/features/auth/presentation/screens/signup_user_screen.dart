import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/validators/auth_validator.dart';
import 'package:frontend/widgets/curved_header.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

class SignupUserScreen extends StatefulWidget {
  const SignupUserScreen({Key? key}) : super(key: key);

  @override
  State<SignupUserScreen> createState() => _SignupUserScreenState();
}

class _SignupUserScreenState extends State<SignupUserScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final err = await AuthValidator.validateAllFieldsForSignUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      isMedic: false,
    );

    if (!mounted) return;
    if (err != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(err),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final authCtrl = context.read<AuthController>()
      ..email = _emailCtrl.text.trim()
      ..password = _passwordCtrl.text;

    await authCtrl.signup(
      context: context,
      isMedic: false,
      email: _emailCtrl.text.trim(),
      firstName:_firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      confirmPassword:_confirmPasswordCtrl.text,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const CurvedHeader(title: 'Create Account', showBack: true),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,    // same overlay as login
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _lastNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordCtrl,
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
                      controller: _confirmPasswordCtrl,
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
            ],
          ),
        ),
      ),
    );
  }
}
