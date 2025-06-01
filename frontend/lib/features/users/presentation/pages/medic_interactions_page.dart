import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/users/presentation/widgets/medic_interactions_panel.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';

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

    if (confirmed != true) {
      return;
    }

    try {
      await userController.unassignMedic();
    } catch (e) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Medic Interactions'),

              Expanded(
                child: SingleChildScrollView(
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
      ),
    );
  }
}