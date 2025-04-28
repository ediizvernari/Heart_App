import 'package:flutter/material.dart';
import '../services/medic_service.dart';
import '../models/user.dart';
import '../models/user_health_data.dart';
import '../models/user_medical_record.dart';

class AssignedUsersController extends ChangeNotifier {
  final MedicService _medicService;

  bool isLoading = false;
  String? errorMessage;

  List<User> assignedUsers = [];
  final Map<int, UserHealthData> assignedUsersHealthDataMap = {};
  final Map<int, UserMedicalRecord?> assignedUsersLatestRecordMap = {};

  AssignedUsersController(String token) : _medicService = MedicService(token);

  Future<void> fetchAssignedUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      assignedUsers = await _medicService.fetchAssignedUsers();
      assignedUsersHealthDataMap.clear();
      assignedUsersLatestRecordMap.clear();

      for (final u in assignedUsers) {
        if (u.sharesDataWithMedic) {
          try {
            assignedUsersHealthDataMap[u.id] =
                await _medicService.fetchAssignedUserHealthData(u.id);
          } catch (_) { /* ignore */ }
        }

        try {
          assignedUsersLatestRecordMap[u.id] =
              await _medicService.fetchLatestPatientMedicalRecord(u.id);
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
