import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import '../../../../core/api_constants.dart';
import '../../../../services/api_client.dart';
import '../models/user_medical_record.dart';

class UserMedicalRecordApi {
  static Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // Used by the medic
  static Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser(String token) async {
    final response = await APIClient.get(
      APIConstants.getAllMedicalRecordsForUserUrl,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List;
    return list.map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<UserMedicalRecord> getLatestUserMedicalRecord(String token) async {
    final response = await APIClient.get(
      APIConstants.getLatestMedicalRecordForUserUrl,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw throw ApiException(response.statusCode, response.body);
    }
    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }

  // Used by the user
  static Future<List<UserMedicalRecord>> getAllMedicalRecordsByUserId(String token, int userId) async {
    final response = await APIClient.get(
      APIConstants.getAllMedicalRecordsByUserIdUrl(userId),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) throw ApiException(response.statusCode, response.body);
    return (jsonDecode(response.body) as List)
        .map((e) => UserMedicalRecord.fromJson(e))
        .toList();
  }

  static Future<UserMedicalRecord> getLatestMedicalRecordByUserId(String token, int userId) async {
    final response = await APIClient.get(
      APIConstants.getLatestMedicalRecordByUserIdUrl(userId),
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }
}