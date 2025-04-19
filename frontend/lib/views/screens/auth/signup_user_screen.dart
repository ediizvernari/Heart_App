import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';

class SignUpUserScreen extends StatelessWidget {
  SignUpUserScreen({super.key});

  final _authController = AuthController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTextField(_firstNameController, 'First Name'),
            _buildTextField(_lastNameController, 'Last Name'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_passwordController, 'Password', obscureText: true),
            _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _authController.handleUserSignUpButton(
                  context: context,
                  email: _emailController.text,
                  password: _passwordController.text,
                  confirmPassword: _confirmPasswordController.text,
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                );
              },
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
