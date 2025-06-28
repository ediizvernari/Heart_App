import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

import '../controllers/medic_availability_controller.dart';
import '../widgets/medic_availability_item.dart';

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
          style: AppTextStyles.errorText
        ),
      );
    }

    if (controller.medicAvailabilities.isEmpty) {
      return const Center(
        child: Text(
          'No availability slots yet.',
          style: AppTextStyles.subheader
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.medicAvailabilities.length,
      itemBuilder: (ctx, index) {
        final medicAvailabilitySlot = controller.medicAvailabilities[index];
        return AvailabilityItem(
          slot: medicAvailabilitySlot,
          onDelete: () {
            _confirmDelete(ctx, medicAvailabilitySlot.id, controller);
          },
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, int availabilitySlotId, MedicAvailabilityController medicAvailabilityController) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this slot?'),
        content: const Text('Are you sure you want to delete this availability slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: AppTextStyles.canceldialogButton
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              medicAvailabilityController.removeAvailability(availabilitySlotId);
            },
            child: const Text(
              'Delete',
              style: AppTextStyles.dialogButton
            ),
          ),
        ],
      ),
    );
  }
}
