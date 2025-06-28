import 'package:flutter/material.dart';
import 'package:frontend/widgets/ekg_signal.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/auth/presentation/widgets/home_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    if (authController.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(authController.error!),
            actions: [
              TextButton(
                onPressed: () {
                  authController.clearError();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    const ekgData = <double>[0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 1, -1, 0];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final totalWidth = constraints.maxWidth;
          return Stack(
            children: [
              Container(
                width: totalWidth,
                height: totalHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),

              const SafeArea(
                child: Column(
                  children: [
                    CustomAppBar(title: 'Welcome to the Heart App!'),
                    Expanded(child: Center(child: HomeForm())),
                  ],
                ),
              ),

              EkgSignal(
                data: ekgData,
                bottomOffset: totalHeight * 0.15,
                height: totalHeight * 0.1,
              ),
            ],
          );
        },
      ),
    );
  }
}