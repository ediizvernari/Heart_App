import 'package:frontend/services/api_exception.dart';
import '../api/user_medical_record_api.dart';
import '../models/user_medical_record.dart';
import 'user_medical_record_repository.dart';

class UserMedicalRecordImpl implements UserMedicalRecordRepository {
  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    try {
      return await UserMedicalRecordApi.getAllMedicalRecordsForUser();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserMedicalRecord> getLatestUserMedicalRecord() async {
    try {
      return await UserMedicalRecordApi.getLatestUserMedicalRecord();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId) async {
    try {
      return await UserMedicalRecordApi.getAllMedicalRecordsByUserId(userId);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId) async {
    try {
      return await UserMedicalRecordApi.getLatestMedicalRecordByUserId(userId);
    } on ApiException {
      rethrow;
    }
  }
}