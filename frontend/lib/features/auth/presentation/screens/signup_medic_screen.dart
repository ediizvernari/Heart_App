import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/validators/auth_validator.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

class SignupMedicScreen extends StatefulWidget {
  const SignupMedicScreen({Key? key}) : super(key: key);

  @override
  State<SignupMedicScreen> createState() => _SignupMedicScreenState();
}

class _SignupMedicScreenState extends State<SignupMedicScreen> {
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
    final err = await AuthValidator.validateAllFieldsForSignUp(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      isMedic: true,
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
    setState(() => _step = 1);
  }

  Future<void> _handleSignup() async {
    final authCtrl = context.read<AuthController>()
      ..email = _emailController.text.trim()
      ..password = _passwordController.text;

    await authCtrl.signup(
      context: context,
      isMedic: true,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      confirmPassword:_confirmPasswordController.text,
      streetAddress: _streetController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
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
            const CustomAppBar(title: 'Create a medic account'),
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
                      child: _step == 0 ? _buildStep0() : _buildStep1(authCtrl),
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

  Widget _buildStep0() => Column(
    children: [
      _field(_firstNameController, 'First Name'),
      const SizedBox(height: 16),
      _field(_lastNameController, 'Last Name'),
      const SizedBox(height: 16),
      Directionality(
        textDirection: TextDirection.ltr,
        child: _field(_emailController, 'Email', keyboard: TextInputType.emailAddress),
      ),
      const SizedBox(height: 16),
      _field(_passwordController, 'Password', obscure: true),
      const SizedBox(height: 16),
      _field(_confirmPasswordController, 'Confirm Password', obscure: true),
      const SizedBox(height: 24),
      RoundedButton(text: 'Next', onPressed: _handleNext),
    ],
  );

  Widget _buildStep1(dynamic authCtrl) => Column(
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
            flex: 1,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Back'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: authCtrl.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RoundedButton(text: 'Sign Up', onPressed: _handleSignup),
          ),
        ],
      ),
    ],
  );

  Widget _field(
    TextEditingController ctl,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
