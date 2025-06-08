import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
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
          style: AppTextStyles.dialogContent.copyWith(
            color: AppColors.primaryRed,
          ),
        ),
      );
    }
    if (controller.medicAvailabilities.isEmpty) {
      return Center(
        child: Text(
          'No availability slots yet.',
          style: AppTextStyles.dialogContent.copyWith(
            color: Colors.black54,
          ),
        ),
      );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'Delete this slot?',
          style: AppTextStyles.dialogTitle.copyWith(
            color: AppColors.primaryRed,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.dialogButton.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctl.removeAvailability(slotId);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.dialogButton.copyWith(
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
