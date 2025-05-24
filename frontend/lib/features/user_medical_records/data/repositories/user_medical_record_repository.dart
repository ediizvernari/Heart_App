import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';

abstract class UserMedicalRecordRepository {
  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser();
  Future<UserMedicalRecord> getLatestUserMedicalRecord();
  Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId);
  Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId);
}