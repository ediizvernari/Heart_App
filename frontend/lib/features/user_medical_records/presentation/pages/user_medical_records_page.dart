import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import '../controllers/user_medical_record_controller.dart';
import '../widgets/user_medical_record_card.dart';

class UserMedicalRecordsPage extends StatefulWidget {
  const UserMedicalRecordsPage({Key? key}) : super(key: key);

  @override
  State<UserMedicalRecordsPage> createState() => _UserMedicalRecordsPageState();
}

class _UserMedicalRecordsPageState extends State<UserMedicalRecordsPage> {
  late UserMedicalRecordController _userMedicalRecordController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _userMedicalRecordController = context.read<UserMedicalRecordController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _userMedicalRecordController.getAllMedicalRecords();
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: CustomAppBar(title: 'My Medical Records'),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Consumer<UserMedicalRecordController>(
                        builder: (_, c, __) {
                          if (c.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (c.error != null) {
                            return Center(
                              child: Text(
                                'Error: ${c.error}',
                                style: AppTextStyles.errorText,
                              ),
                            );
                          }
                          if (c.medicalRecords.isEmpty) {
                            return const Center(
                              child: Text(
                                'No medical records.',
                                style: AppTextStyles.subheader,
                              ),
                            );
                          }
                          final records = c.medicalRecords.reversed.toList();

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: records.length,
                            itemBuilder: (_, i) {
                              final rec = records[i];
                              return UserMedicalRecordCard(userMedicalRecord: rec);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
