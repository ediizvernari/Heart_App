import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/user_medical_record.dart';
import '../../data/repositories/user_medical_record_repository.dart';

class UserMedicalRecordController extends ChangeNotifier{
  final UserMedicalRecordRepository _userMedicalRecordRepository;

  UserMedicalRecordController(this._userMedicalRecordRepository);

  List<UserMedicalRecord> _myMedicalRecords = [];
  UserMedicalRecord? _myLatestUserMedicalRecord;
  bool _isLoading = false;
  String? _error;

  List<UserMedicalRecord> get medicalRecords => List.unmodifiable(_myMedicalRecords);
  UserMedicalRecord? get latestMedicalREcord  => _myLatestUserMedicalRecord;
  bool get isLoading => _isLoading;
  String? get error     => _error;

  Future<void> getAllMedicalRecords() async {
    _setLoading(true);

    try {
      _myMedicalRecords = await _userMedicalRecordRepository.getAllMedicalRecordsForUser();
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getLatestUserMedicalRecord() async {
    _setLoading(true);

    try {
      _myLatestUserMedicalRecord = await _userMedicalRecordRepository.getLatestUserMedicalRecord();
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