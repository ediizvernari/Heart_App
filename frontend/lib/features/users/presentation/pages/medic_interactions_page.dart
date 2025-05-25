import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/action_card.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../controllers/user_controller.dart';

class MedicInteractionsPage extends StatelessWidget {
  const MedicInteractionsPage({Key? key}) : super(key: key);

  Future<void> _confirmUnassign(BuildContext context) async {
    final userController = context.read<UserController>();
    final bool? confirmedUnassignment = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unassign Medic'),
        content: const Text('Are you sure you want to unassign your medic?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
    if (confirmedUnassignment == true) {
      await userController.unassignMedic();
      await userController.getMyAssignmentStatus();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          title: 'Medic Interactions',
          onBack: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ActionCard(
                      icon: Icons.message,
                      label: 'Suggestions',
                      onTap: () => Navigator.pushNamed(context, '/user-suggestions'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ActionCard(
                      icon: Icons.link_off,
                      label: 'Unassign Medic',
                      onTap: () => _confirmUnassign(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 2,
              child: ActionCard(
                icon: Icons.event_note,
                label: 'My Appointments',
                onTap: () => Navigator.pushNamed(context, '/user-appointments'),
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}