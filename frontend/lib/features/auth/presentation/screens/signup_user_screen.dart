import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/widgets/signup_user_form.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

class SignupUserScreen extends StatelessWidget {
  const SignupUserScreen({super.key});

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
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'Create a user account'),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: SignupUserForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
