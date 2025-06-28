import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/medical_services/presentation/widgets/medical_service_item.dart';


class MedicalServicesBody extends StatelessWidget {
  final int selectedMedicalServiceTypeId;
  final ValueChanged<int> onTypeSelected;

  const MedicalServicesBody({
    Key? key,
    required this.selectedMedicalServiceTypeId,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final medicalServiceController = context.watch<MedicalServiceController>();

    final allTypes = [
      _FakeType(id: 0, name: 'All'),
      ...medicalServiceController.medicalServiceTypes.map((t) => _FakeType(id: t.id, name: t.name)),
    ];

    final filtered = selectedMedicalServiceTypeId == 0
        ? medicalServiceController.medicalServices
        : medicalServiceController.medicalServices
            .where((s) => s.medicalServiceTypeId == selectedMedicalServiceTypeId)
            .toList();

    if (medicalServiceController.loadingTypes || medicalServiceController.loadingServices) {
      return const Center(child: CircularProgressIndicator());
    }
    if (medicalServiceController.error != null) {
      return Center(
        child: Text('Error: ${medicalServiceController.error}',
            style: AppTextStyles.errorText),
      );
    }
    if (filtered.isEmpty) {
      return const Center(
        child: Text('No services found.',
            style: AppTextStyles.heading1),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final type = allTypes[i];
                final isSelected = type.id == selectedMedicalServiceTypeId;
                return ChoiceChip(
                  label: Text(type.name,
                      style: AppTextStyles.subheader.copyWith(
                        color: isSelected ? AppColors.background : AppColors.textPrimary,
                      )),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.background,
                  onSelected: (_) => onTypeSelected(type.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final filteredMedicalService = filtered[index];
                return MedicalServiceItem(service: filteredMedicalService);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeType {
  final int id;
  final String name;
  _FakeType({required this.id, required this.name});
}
