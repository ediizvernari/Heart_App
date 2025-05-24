import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/services/api_exception.dart';
import '../api/user_medical_record_api.dart';
import '../models/user_medical_record.dart';
import 'user_medical_record_repository.dart';

class UserMedicalRecordImpl implements UserMedicalRecordRepository {
  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    final String? token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserMedicalRecordApi.getAllMedicalRecordsForUser(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserMedicalRecord> getLatestUserMedicalRecord() async {
    final String? token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserMedicalRecordApi.getLatestUserMedicalRecord(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId) async {
    final String? token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserMedicalRecordApi.getAllMedicalRecordsByUserId(token, userId);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId) async {
    final String? token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserMedicalRecordApi.getLatestMedicalRecordByUserId(token, userId);
    } on ApiException {
      rethrow;
    }
  }
}