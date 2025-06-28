import 'package:frontend/features/user_medical_records/data/api/user_medical_record_api.dart';
import '../models/user_medical_record.dart';
import 'user_medical_record_repository.dart';

class UserMedicalRecordRepositoryImpl implements UserMedicalRecordRepository {
  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() {
    return UserMedicalRecordApi.getAllMedicalRecordsForUser();
  }

  @override
  Future<UserMedicalRecord> getLatestUserMedicalRecord() {
    return UserMedicalRecordApi.getLatestUserMedicalRecord();
  }

  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId) {
    return UserMedicalRecordApi.getAllMedicalRecordsByUserId(userId);
  }

  @override
  Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId) {
    return UserMedicalRecordApi.getLatestMedicalRecordByUserId(userId);
  }
}