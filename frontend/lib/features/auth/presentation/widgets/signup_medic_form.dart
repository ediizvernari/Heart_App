import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/utils/validators/auth_validator.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';

class SignupMedicForm extends StatefulWidget {
  const SignupMedicForm({super.key});
  @override
  State<SignupMedicForm> createState() => _SignupMedicFormState();
}

class _SignupMedicFormState extends State<SignupMedicForm> {
  int _step = 0;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final error = await AuthValidator.validateAllFieldsForSignUp(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword:_confirmPasswordController.text,
      isMedic: true,
    );
    if (!mounted) return;
    if (error != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _handleSignup() async {
    final dto = MedicSignupRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      streetAddress: _streetController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
    );
    final authCtrl = context.read<AuthController>()
      ..email = dto.email
      ..password = dto.password;

    await authCtrl.signupMedic(
      context: context,
      medicSignupDto: dto,
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
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _step == 0 ? _buildStep0() : _buildStep1(),
        ),
      ),
    );
  }

  Widget _buildStep0() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _field(_firstNameController, 'First Name'),
      const SizedBox(height: 16),
      _field(_lastNameController, 'Last Name'),
      const SizedBox(height: 16),
      _field(_emailController, 'Email', keyboard: TextInputType.emailAddress),
      const SizedBox(height: 16),
      _field(_passwordController,'Password', obscure: true),
      const SizedBox(height: 16),
      _field(_confirmPasswordController, 'Confirm Password', obscure: true),
      const SizedBox(height: 24),
      RoundedButton(
        text: 'Next',
        onPressed: _handleNext,
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        borderRadius: 30,
        elevation: 8,
      ),
    ],
  );

  Widget _buildStep1() {
    final authCtrl = context.read<AuthController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _field(_streetController, 'Street Address'),
        const SizedBox(height: 16),
        _field(_cityController, 'City'),
        const SizedBox(height: 16),
        _field(_countryController, 'Country'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: RoundedButton(
                text: 'Back',
                onPressed: () => setState(() => _step = 0),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                borderRadius: 30,
                elevation: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: authCtrl.isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)))
                : RoundedButton(
                    text: 'Sign Up',
                    onPressed: _handleSignup,
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    borderRadius: 30,
                    elevation: 8,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctl,
    String hint, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
