import 'package:dio/dio.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/user_medical_record.dart';

class UserMedicalRecordApi {
  static Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicalRecordsForUserUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load your medical records.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<UserMedicalRecord> getLatestUserMedicalRecord() async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(APIConstants.getLatestMedicalRecordForUserUrl);

      if (response.statusCode == 200 && response.data != null) {
        return UserMedicalRecord.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load latest medical record.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(int userId) async {
    try {
      final String url = APIConstants.getAllMedicalRecordsByUserIdUrl(userId);
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medical records for user $userId.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<UserMedicalRecord> getLatestMedicalRecordByUserId(int userId) async {
    try {
      final String url = APIConstants.getLatestMedicalRecordByUserIdUrl(userId);
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        return UserMedicalRecord.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load latest medical record for user $userId.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }
}