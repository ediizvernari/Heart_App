import 'dart:convert';
import 'package:frontend/features/medics/data/models/assigned_users.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';
import 'package:frontend/services/api_exception.dart';
import '../../../../core/api_constants.dart';
import '../../../../services/api_client.dart';
import '../models/medic.dart';

class MedicApi {
  static Map<String,String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  static Future<List<Medic>> getFilteredMedicsByLocation(String? city, String? country, String token) async {
    final uri = Uri.parse(APIConstants.getFilteredMedicsUrl)
        .replace(queryParameters: {
          if (city != null) 'city': city,
          if (country != null) 'country': country,
        });
    
    final response = await APIClient.get(uri.toString(), headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return (jsonDecode(response.body) as List)
        .map((e) => Medic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AssignedUser>> getAssignedUsers(String token) async {
    final response = await APIClient.get(APIConstants.getAssignedPatientsUrl, headers: _authHeaders(token));

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return (jsonDecode(response.body) as List)
        .map((e) => AssignedUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<UserHealthData> getAssignedUserHealthData(String token, int userId) async {
    final url = APIConstants.getPatientHealthDataUrl(userId);

    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    } 

    return UserHealthData.fromJson(jsonDecode(response.body));
  }

  static Future<List<UserMedicalRecord>> getAssignedUserAllMedicalRecords(String token, int userId) async {
    final url = APIConstants.getAssignedUserAllMedicalRecordsUrl(userId);

    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return (jsonDecode(response.body) as List)
        .map((e) => UserMedicalRecord.fromJson(e))
        .toList();
  }

  static Future<UserMedicalRecord> getLatestMedicalRecord(String token, int userId) async {
    final url = APIConstants.getAssignedUserLatestMedicalRecordUrl(userId);
    
    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    } 

    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }
}
