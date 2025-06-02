import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../controllers/medic_availability_controller.dart';
import 'medic_availability_item.dart';

class AvailabilityBody extends StatelessWidget {
  final MedicAvailabilityController controller;

  const AvailabilityBody({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(
        child: Text(
          'Error: ${controller.error}',
          style: const TextStyle(color: AppColors.primaryRed)
        ),
      );
    }
    if (controller.medicAvailabilities.isEmpty) {
      return const Center(child: Text('No availability slots yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.medicAvailabilities.length,
      itemBuilder: (ctx, index) {
        final slot = controller.medicAvailabilities[index];
        return AvailabilityItem(
          slot: slot,
          onDelete: () {
            _confirmDelete(ctx, slot.id, controller);
          },
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext ctx, int slotId, MedicAvailabilityController ctl) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete this slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctl.removeAvailability(slotId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
