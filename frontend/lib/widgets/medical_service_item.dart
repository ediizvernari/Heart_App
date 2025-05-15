import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medical_service.dart';
import '../controllers/medical_service_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'medical_service_form_dialog.dart';

class MedicalServiceItem extends StatelessWidget {
  final MedicalService service;

  const MedicalServiceItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ctl = context.read<MedicalServiceController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(service.name, style: AppTextStyles.buttonText),
        subtitle: Text(
          '\$${service.price} • ${service.durationMinutes} min',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.softGrey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.primaryRed,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => ChangeNotifierProvider.value(
                    value: ctl,
                    child: MedicalServiceFormDialog(service: service),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppColors.primaryRed,
              onPressed: () => ctl.deleteMedicalService(service.id),
            ),
          ],
        ),
      ),
    );
  }
}
