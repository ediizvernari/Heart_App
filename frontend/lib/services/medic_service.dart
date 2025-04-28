import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/user_health_data.dart';
import 'package:frontend/models/user_medical_record.dart';
import '../core/api_constants.dart';
import 'api_client.dart';
import '../models/medic.dart';

class MedicService {

  final String _token;
  late final Map<String, String> _headers;

  MedicService(this._token) {
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_token',
    };
  }

  static Future<List<Medic>> fetchFilteredMedics({
    String? city,
    String? country,
  }) async {
    var uri = Uri.parse(APIConstants.getFilteredMedicsUrl);
    final queryParams = <String, String>{};

    if (city != null) queryParams['city'] = city;
    if (country != null) queryParams['country'] = country;
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await APIClient.get(uri.toString());
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch medics: ${response.statusCode}: ${response.body}');
    }

    final medicList = jsonDecode(response.body) as List<dynamic>;
    return medicList.cast<Map<String, dynamic>>()
        .map(Medic.fromJson)
        .toList();
  }

  Future<List<User>> fetchAssignedUsers() async {
    final response = await APIClient.get(APIConstants.getAssignedPatientsUrl, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch assigned patients: ${response.statusCode}: ${response.body}');
    }

    final assignedPatients = jsonDecode(response.body) as List<dynamic>;

    return assignedPatients.cast<Map<String, dynamic>>()
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<UserHealthData> fetchAssignedUserHealthData(int userID) async {
    final url = APIConstants.getPatientHealthDataUrl(userID);

    final response = await APIClient.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user health data: ${response.statusCode}: ${response.body}');
    }

    return UserHealthData.fromJson(jsonDecode(response.body));
  }

  Future<List<UserMedicalRecord>> fetchAllAssignedUserMedicalRecords(int userID) async {
    final url = APIConstants.fetchAllPatientMedicalRecordsUrl(userID);

    final response = await APIClient.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user medical records: ${response.statusCode}: ${response.body}');
    }

    final medicalRecords = jsonDecode(response.body) as List<dynamic>;

    return medicalRecords.cast<Map<String, dynamic>>()
        .map((e) => UserMedicalRecord.fromJson(e))
        .toList();
  }

  Future<UserMedicalRecord> fetchLatestPatientMedicalRecord(int userID) async {
    final url = APIConstants.fetchLatestPatientMedicalRecordUrl(userID);

    final response = await APIClient.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch the latest user medical record: ${response.statusCode}: ${response.body}');
    }

    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }
}