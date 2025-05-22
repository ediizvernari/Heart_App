import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/medical_service_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/medical_service_form_dialog.dart';
import '../widgets/medical_service_item.dart';

//TODO: Put a header here
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

    final filtered = _selectedMedicalServiceTypeId == 0
        ? medicalServiceController.medicalServices
        : medicalServiceController.medicalServices
            .where((s) => s.medicalServiceTypeId == _selectedMedicalServiceTypeId)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Medical Services',
          style: AppTextStyles.welcomeHeader,
        ),
        backgroundColor: AppColors.primaryRed,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final medicalServiceType = allTypes[i];
                  final selectedMedicalserviceType = medicalServiceType.id == _selectedMedicalServiceTypeId;
                  return ChoiceChip(
                    label: Text(medicalServiceType.name),
                    selected: selectedMedicalserviceType,
                    selectedColor: AppColors.primaryRed,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selectedMedicalserviceType ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedMedicalServiceTypeId = medicalServiceType.id;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            if (medicalServiceController.loadingTypes || medicalServiceController.loadingServices)
              const Center(child: CircularProgressIndicator())
            else if (medicalServiceController.error != null)
              Center(child: Text('Error: ${medicalServiceController.error}'))
            else if (filtered.isEmpty)
              const Center(child: Text('No services found.'))

            else
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final svc = filtered[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: MedicalServiceItem(service: svc),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => ChangeNotifierProvider.value(
            value: medicalServiceController,
            child: const MedicalServiceFormDialog(),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FakeType {
  final int id;
  final String name;
  _FakeType({required this.id, required this.name});
}
