import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/user_medical_record.dart';
import '../../data/repositories/user_medical_record_repository.dart';

class MedicsAssignedUserMedicalRecordController extends ChangeNotifier {
  final UserMedicalRecordRepository _userMedicalRecordRepository;

  MedicsAssignedUserMedicalRecordController(this._userMedicalRecordRepository);

  List<UserMedicalRecord> _assienedUserMedicalRecords = [];
  UserMedicalRecord? _assignedUserLatestUserMedicalRecord;
  bool _isLoading = false;
  String? _error;

  List<UserMedicalRecord> get medicalRecords => List.unmodifiable(_assienedUserMedicalRecords);
  UserMedicalRecord? get latestMedicalREcord => _assignedUserLatestUserMedicalRecord;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getAssignedUserAllMedicalRecords(int userId) async {
    _setLoading(true);

    try {
      _assienedUserMedicalRecords = await _userMedicalRecordRepository.getAllMedicalRecordsByUserId(userId);
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getAssignedUserLatestUserMedicalRecord(int userId) async {
    _setLoading(true);

    try {
      _assignedUserLatestUserMedicalRecord = await _userMedicalRecordRepository.getLatestMedicalRecordByUserId(userId);
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}