import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/medical_service_controller.dart';
import '../../data/models/medical_service.dart';
import 'medical_service_form_dialog.dart';

class MedicalServiceItem extends StatelessWidget {
  final MedicalService service;

  const MedicalServiceItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final medicalServiceController = context.read<MedicalServiceController>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.header.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${service.price.toStringAsFixed(2)} • ${service.durationMinutes} min',
                    style: AppTextStyles.subheader.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primaryRed,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => ChangeNotifierProvider.value(
                        value: medicalServiceController,
                        child: MedicalServiceFormDialog(service: service),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.primaryRed,
                  onPressed: () {
                    medicalServiceController.deleteMedicalService(service.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
