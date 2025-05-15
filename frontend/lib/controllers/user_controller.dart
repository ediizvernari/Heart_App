import 'package:flutter/material.dart';
import '../models/medic.dart';
import '../models/user_medical_record.dart';
import '../services/user_service.dart';
import '../services/api_exception.dart';

class UserController extends ChangeNotifier {
  final UserService _service;

  UserController() : _service = UserService();

  bool isLoading = false;
  String? error;

  bool hasMedic = false;
  Map<String, dynamic>? assignmentStatus;
  Medic? assignedMedic;
  List<UserMedicalRecord> medicalRecords = [];

  Future<void> _setLoading(Future<void> Function() fn) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await fn();
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkHasMedic() async {
    await _setLoading(() async {
      hasMedic = await _service.checkUserHasMedic();
    });
  }

  Future<void> fetchAssignmentStatus() async {
    await _setLoading(() async {
      assignmentStatus = await _service.getAssignmentStatus();
    });
  }

  Future<void> fetchAssignedMedic() async {
    await _setLoading(() async {
      assignedMedic = await _service.getAssignedMedic();
    });
  }

  Future<void> fetchAllMedicalRecords() async {
    await _setLoading(() async {
      medicalRecords = await _service.getAllMedicalRecordsForUser();
    });
  }

  Future<void> fetchLatestMedicalRecord() async {
    await _setLoading(() async {
      final rec = await _service.getLatestMedicalRecordForUser();
      if (medicalRecords.isEmpty) {
        medicalRecords = [rec];
      } else {
        medicalRecords[0] = rec;
      }
    });
  }
}