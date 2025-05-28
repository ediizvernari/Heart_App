import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class AutoCheck extends StatefulWidget {
  const AutoCheck({Key? key}) : super(key: key);

  @override
  State<AutoCheck> createState() => _AutoCheckState();
}

class _AutoCheckState extends State<AutoCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      authController.ensureSession(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
