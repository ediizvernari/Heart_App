import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/user_medical_record.dart';

class UserMedicalRecordApi {
  static Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicalRecordsForUserUrl);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load your medical records.');
  }

  static Future<UserMedicalRecord> getLatestUserMedicalRecord() async {
    final response = await ApiClient.get<Map<String, dynamic>>(APIConstants.getLatestMedicalRecordForUserUrl);

    if (response.statusCode == 200 && response.data != null) {
      return UserMedicalRecord.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load latest medical record.');
  }

  static Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId) async {
    final url = APIConstants.getAllMedicalRecordsByUserIdUrl(userId);
    final response = await ApiClient.get<List<dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medical records for user $userId.');
  }

  static Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId) async {
    final url = APIConstants.getLatestMedicalRecordByUserIdUrl(userId);
    final response = await ApiClient.get<Map<String, dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      return UserMedicalRecord.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load latest medical record for user $userId.');
  }
}