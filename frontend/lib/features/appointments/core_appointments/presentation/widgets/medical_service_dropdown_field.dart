import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/medical_services/data/models/medical_service.dart';

class MedicalServiceDropdownField extends StatelessWidget {
  final List<MedicalService> medicalServices;
  final int? selectedMedicalServiceId;
  final ValueChanged<int?> onChanged;

  const MedicalServiceDropdownField({
    Key? key,
    required this.medicalServices,
    required this.selectedMedicalServiceId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medicalServices.isEmpty) {
      return const Text(
        'No medical services available',
        style: TextStyle(color: Colors.black54, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Select Service',
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dropdownColor: AppColors.cardBackground,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!,
      isExpanded: true,
      value: selectedMedicalServiceId,
      items: medicalServices
          .map(
            (s) => DropdownMenuItem(
              value: s.id,
              child: Text(
                '${s.name} – \$${s.price.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}