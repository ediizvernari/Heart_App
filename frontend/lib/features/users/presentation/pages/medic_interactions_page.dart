import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/user_controller.dart';

class MedicInteractionsPage extends StatelessWidget {
  const MedicInteractionsPage({Key? key}) : super(key: key);

  Future<void> _confirmUnassign(BuildContext context) async {
    final userController = context.read<UserController>();
    final ok = await showDialog<bool>(
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
    if (ok == true) {
      await userController.unassignMedic();
      await userController.checkUserHasMedic();
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
                    child: _ActionCard(
                      icon: Icons.message,
                      label: 'Suggestions',
                      onTap: () => Navigator.pushNamed(
                          context, '/user-suggestions'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _ActionCard(
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
              child: _ActionCard(
                icon: Icons.event_note,
                label: 'My Appointments',
                onTap: () =>
                    Navigator.pushNamed(context, '/user-appointments'),
                isBig: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isBig;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isBig = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = isBig ? AppColors.primaryRed : Colors.grey[800]!;
    final textColor = isBig ? AppColors.primaryRed : Colors.black;
    final iconSize = isBig ? 64.0 : 48.0;
    final fontSize = isBig ? 18.0 : 14.0;

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
