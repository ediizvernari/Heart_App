import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/widgets/appointment_medic_suggestion_form_dialog.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/features/medics/data/repositories/medic_repository_impl.dart';
import 'package:frontend/features/medics/presentation/controllers/assigned_users_controller.dart';
import 'package:frontend/features/users/presentation/widgets/user_card.dart';
import 'package:frontend/features/user_medical_records/presentation/widgets/user_medical_record_card.dart';
import 'package:provider/provider.dart';

class MedicPatientsPage extends StatefulWidget {
  const MedicPatientsPage({Key? key}) : super(key: key);

  @override
  _MedicPatientsPageState createState() => _MedicPatientsPageState();
}

class _MedicPatientsPageState extends State<MedicPatientsPage> {
  late AssignedUsersController _assignedUsersController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _assignedUsersController = AssignedUsersController(MedicRepositoryImpl());
      await _assignedUsersController.getAssignedUsers();
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: CustomAppBar(title: 'My Patients'),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ChangeNotifierProvider.value(
                        value: _assignedUsersController,
                        child: Consumer<AssignedUsersController>(
                          builder: (ctx, c, _) {
                            if (c.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (c.errorMessage != null) {
                              return Center(
                                child: Text(
                                  'Error: ${c.errorMessage}',
                                  style: AppTextStyles.errorText,
                                ),
                              );
                            }
                            if (c.assignedUsers.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No assigned patients.',
                                  style: AppTextStyles.subheader,
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 16, bottom: 80),
                              itemCount: c.assignedUsers.length,
                              itemBuilder: (_, i) {
                                final user = c.assignedUsers[i];
                                final rec = c.assignedUsersLatestRecordMap[user.id];
                                return UserCard(
                                  user: user,
                                  recordCard: rec != null
                                      ? UserMedicalRecordCard(userMedicalRecord: rec)
                                      : null,
                                  onSuggest: () => showDialog(
                                    context: context,
                                    builder: (_) => SuggestionFormDialog(userId: user.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
