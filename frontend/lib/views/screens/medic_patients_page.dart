import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/app_colors.dart';
import '../../utils/validators/session_validator.dart';
import '../../controllers/assigned_users_controller.dart';
import '../../models/user.dart';
import '../../widgets/user_medical_record_card.dart';
import '../../widgets/appointment_medic_suggestion_form_dialog.dart';

class MedicPatientsPage extends StatefulWidget {
  const MedicPatientsPage({Key? key}) : super(key: key);

  @override
  State<MedicPatientsPage> createState() => _MedicPatientsPageState();
}

class _MedicPatientsPageState extends State<MedicPatientsPage> {
  final _storage = const FlutterSecureStorage();
  bool _loadingToken = true;
  late AssignedUsersController _ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      final token = await _storage.read(key: 'auth_token') ?? '';
      _ctrl = AssignedUsersController(token);
      await _ctrl.fetchAssignedUsers();
      setState(() => _loadingToken = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: ChangeNotifierProvider.value(
        value: _ctrl,
        child: Consumer<AssignedUsersController>(
          builder: (_, c, __) {
            if (c.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.errorMessage != null) {
              return Center(
                child: Text(
                  c.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (c.assignedUsers.isEmpty) {
              return const Center(child: Text('No assigned patients.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: c.assignedUsers.length,
              itemBuilder: (context, i) {
                final User u = c.assignedUsers[i];
                final shared = u.sharesDataWithMedic;
                final hd = c.assignedUsersHealthDataMap[u.id];
                final rec = c.assignedUsersLatestRecordMap[u.id];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text('${u.firstName} ${u.lastName}'),
                    subtitle: Text(
                      shared ? 'Data shared' : 'No data shared',
                      style: TextStyle(
                        color: shared ? Colors.green : Colors.grey,
                      ),
                    ),
                    children: [
                      if (shared && hd != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Birth Date: ${hd.dateOfBirth}'),
                              // …
                            ],
                          ),
                        ),
                      ],
                      const Divider(),
                      if (rec == null)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No medical record available.'),
                        )
                      else
                        UserMedicalRecordCard(
                          assignedUserMedicalRecord: rec,
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Suggest Appointment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => SuggestionFormDialog(
                                  userId: u.id,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
