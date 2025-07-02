import 'package:flutter/material.dart';
import 'package:frontend/widgets/ekg_signal.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/users/presentation/widgets/medic_interactions_panel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';

class MedicInteractionsPage extends StatelessWidget {
  const MedicInteractionsPage({Key? key}) : super(key: key);

  Future<void> _confirmUnassign(BuildContext context) async {
    final userController = context.read<UserController>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unassign Medic'),
        content: const Text('Are you sure you want to unassign your medic?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await userController.unassignMedic();
      await userController.getMyAssignmentStatus();
    } catch (e) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const CustomAppBar(title: 'Interact with Your Medic'),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: MedicInteractionsPanel(
                          onSuggestions: () => Navigator.pushNamed(context, '/user-suggestions'),
                          onUnassign: () => _confirmUnassign(context),
                          onAppointments: () => Navigator.pushNamed(context, '/user-appointments'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              EkgSignal(
                data: const <double>[
                  0, 0, 1, -1, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 1, -1, 0],
                bottomOffset: screenHeight * 0.15,
                height: screenHeight * 0.1,
              ),
            ],
          );
        },
      ),
    );
  }
}