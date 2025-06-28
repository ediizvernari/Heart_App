import 'package:flutter/material.dart';
import 'package:frontend/features/medical_services/presentation/widgets/medical_service_form_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../controllers/medical_service_controller.dart';
import '../widgets/medical_service_item.dart';

class MedicalServicesPage extends StatefulWidget {
  const MedicalServicesPage({Key? key}) : super(key: key);

  @override
  _MedicalServicesPageState createState() => _MedicalServicesPageState();
}

class _MedicalServicesPageState extends State<MedicalServicesPage> {
  int _selectedMedicalServiceTypeId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicalServiceController = context.read<MedicalServiceController>();
      if (!medicalServiceController.loadingTypes && !medicalServiceController.loadingServices) {
        medicalServiceController.getAllMedicalServiceData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicalServiceController = context.watch<MedicalServiceController>();

    final allTypes = [
      _FakeType(id: 0, name: 'All'),
      ...medicalServiceController.medicalServiceTypes.map((t) => _FakeType(id: t.id, name: t.name)),
    ];

    final filteredServices = _selectedMedicalServiceTypeId == 0
        ? medicalServiceController.medicalServices
        : medicalServiceController.medicalServices
            .where((s) => s.medicalServiceTypeId == _selectedMedicalServiceTypeId)
            .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'My Medical Services'),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allTypes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final type = allTypes[i];
                            final isSelected =
                                type.id == _selectedMedicalServiceTypeId;
                            return ChoiceChip(
                              label: Text(
                                type.name,
                                style: AppTextStyles.subheader.copyWith(
                                  color: isSelected
                                      ? AppColors.background
                                      : AppColors.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor: AppColors.background,
                              onSelected: (_) {
                                setState(() {
                                  _selectedMedicalServiceTypeId = type.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (medicalServiceController.loadingTypes ||
                          medicalServiceController.loadingServices) ...[
                        const Center(child: CircularProgressIndicator())
                      ] else if (medicalServiceController.error != null) ...[
                        Center(
                          child: Text(
                            'Error: ${medicalServiceController.error}',
                            style: AppTextStyles.errorText
                          ),
                        )
                      ] else if (filteredServices.isEmpty) ...[
                        Center(
                          child: Text(
                            'No services found.',
                            style: AppTextStyles.dialogContent.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      ] else ...[
                        Expanded(
                          child: ListView.separated(
                            itemCount: filteredServices.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              final svc = filteredServices[index];
                              return MedicalServiceItem(service: svc);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: medicalServiceController,
              child: const MedicalServiceFormDialog(),
            ),
          );
        },
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}

class _FakeType {
  final int id;
  final String name;
  _FakeType({required this.id, required this.name});
}