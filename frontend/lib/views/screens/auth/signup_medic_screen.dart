import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';

class SignUpMedicScreen extends StatefulWidget {
  const SignUpMedicScreen({super.key});

  @override
  State<SignUpMedicScreen> createState() => _SignUpMedicPageState();
}

class _SignUpMedicPageState extends State<SignUpMedicScreen> {
  final _pageController = PageController();
  final _authController = AuthController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medic Sign Up")),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildStepOne(), _buildStepTwo()],
      ),
    );
  }

  Widget _buildStepOne() {
    return _stepContainer(
      children: [
        _buildField(_firstNameController, "First Name"),
        _buildField(_lastNameController, "Last Name"),
        _buildField(_emailController, "Email"),
        _buildField(_passwordController, "Password", obscure: true),
        _buildField(_confirmPasswordController, "Confirm Password", obscure: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final error = await _authController.validateMedicStepOneFields(
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            );
            if (error != null) {
              _showError(error);
            } else {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
            }
          },
          child: const Text("Next"),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return _stepContainer(
      children: [
        _buildField(_streetAddressController, "Street Address"),
        _buildField(_cityController, "City"),
        _buildField(_postalCodeController, "Postal Code"),
        _buildField(_countryController, "Country"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final error = await _authController.validateMedicStepTwoFields(
              streetAddress: _streetAddressController.text,
              city: _cityController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
            );
            if (error != null) {
              _showError(error);
              return;
            }

            await _authController.handleMedicSignUpButton(
              context: context,
              email: _emailController.text,
              password: _passwordController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              streetAddress: _streetAddressController.text,
              city: _cityController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
            );
          },
          child: const Text("Sign Up"),
        ),
      ],
    );
  }

  Widget _stepContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: children,
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Validation Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
