import 'package:flutter/material.dart';

import '../models/medical_service_type.dart';
import '../models/medical_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'medical_service_item.dart';

class MedicalServiceTypeTile extends StatelessWidget {
  final MedicalServiceType type;
  final List<MedicalService> services;

  const MedicalServiceTypeTile({
    super.key,
    required this.type,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        type.name,
        style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryRed),
      ),
      children: services
          .map((svc) => MedicalServiceItem(service: svc))
          .toList(),
    );
  }
}
