import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/validators/auth_validator.dart';
import 'package:frontend/widgets/curved_header.dart';
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

  final _firstNameCtrl       = TextEditingController();
  final _lastNameCtrl        = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _streetCtrl          = TextEditingController();
  final _cityCtrl            = TextEditingController();
  final _countryCtrl         = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    // Run the common signup validators first:
    final err = await AuthValidator.validateAllFieldsForSignUp(
      email:           _emailCtrl.text.trim(),
      password:        _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
      firstName:       _firstNameCtrl.text.trim(),
      lastName:        _lastNameCtrl.text.trim(),
      isMedic:         true,
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
    // Finally, call the controller with all fields:
    final authCtrl = context.read<AuthController>()
      ..email    = _emailCtrl.text.trim()
      ..password = _passwordCtrl.text;

    await authCtrl.signup(
      context:        context,
      isMedic:        true,
      firstName:      _firstNameCtrl.text.trim(),
      lastName:       _lastNameCtrl.text.trim(),
      confirmPassword:_confirmPasswordCtrl.text,
      streetAddress:  _streetCtrl.text.trim(),
      city:           _cityCtrl.text.trim(),
      country:        _countryCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();

    // same login‐style popup for any controller.error
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
              const CurvedHeader(title: 'Register Medic', showBack: true),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _step == 0 ? _buildStep0() : _buildStep1(authCtrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep0() => Column(
    children: [
      _field(_firstNameCtrl,       'First Name'),
      const SizedBox(height: 16),
      _field(_lastNameCtrl,        'Last Name'),
      const SizedBox(height: 16),
      Directionality(
        textDirection: TextDirection.ltr,
        child: _field(_emailCtrl,   'Email', keyboard: TextInputType.emailAddress),
      ),
      const SizedBox(height: 16),
      _field(_passwordCtrl,        'Password', obscure: true),
      const SizedBox(height: 16),
      _field(_confirmPasswordCtrl, 'Confirm Password', obscure: true),
      const SizedBox(height: 24),
      RoundedButton(text: 'Next', onPressed: _handleNext),
    ],
  );

  Widget _buildStep1(dynamic authCtrl) => Column(
    children: [
      _field(_streetCtrl,  'Street Address'),
      const SizedBox(height: 16),
      _field(_cityCtrl,    'City'),
      const SizedBox(height: 16),
      _field(_countryCtrl, 'Country'),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('Back'),
          ),
          authCtrl.isLoading
            ? const CircularProgressIndicator()
            : RoundedButton(text: 'Sign Up', onPressed: _handleSignup),
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
