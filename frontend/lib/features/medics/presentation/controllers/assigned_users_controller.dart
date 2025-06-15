import 'package:flutter/material.dart';
import 'package:frontend/features/medics/data/models/assigned_users.dart';
import 'package:frontend/features/medics/data/repositories/medic_repository.dart';
import '../../../user_health_data/data/models/user_health_data_model.dart';
import '../../../user_medical_records/data/models/user_medical_record.dart';

class AssignedUsersController extends ChangeNotifier {
  final MedicRepository _medicRepository;
  AssignedUsersController(this._medicRepository);

  bool isLoading = false;
  String? errorMessage;

  List<AssignedUser> assignedUsers = [];
  final Map<int, UserHealthData> assignedUsersHealthDataMap = {};
  final Map<int, UserMedicalRecord?> assignedUsersLatestRecordMap = {};

  Future<void> getAssignedUsers() async {
  isLoading     = true;
  errorMessage  = null;
  notifyListeners();

  try {
    assignedUsers = await _medicRepository.getAssignedUsers();
    assignedUsersHealthDataMap.clear();
    assignedUsersLatestRecordMap.clear();

    for (final u in assignedUsers) {
      try {
        assignedUsersLatestRecordMap[u.id] =
          await _medicRepository.getAssignedUserLastMedicalRecord(u.id);
      } catch (_) {
        assignedUsersLatestRecordMap[u.id] = null;
      }
    }
  } catch (e) {
    errorMessage = e.toString();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}
