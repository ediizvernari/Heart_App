import 'dart:convert';
import 'package:frontend/models/medic.dart';
import 'package:frontend/models/user_medical_record.dart';
import '../core/api_constants.dart';
import 'api_client.dart';
import '../utils/auth_store.dart';

class UserService {
  UserService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStore.getToken();
    if (token == null) {
      throw Exception('No auth token available');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> checkUserHasMedic() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.userHasMedicUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to check if user has medic: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return data['has_medic'] as bool;
  }

  Future<Map<String, dynamic>> getAssignmentStatus() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.assignmentStatusUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get assignment status: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> assignMedic(int medicId) async {
    final headers = await _getHeaders();
    final response = await APIClient.post(
      APIConstants.assignMedicUrl,
      {'medic_id': medicId},
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to assign medic: ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> unassignMedic() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.unassignMedicUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to unassign medic: ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> changeSharingPreferenceStatus(bool shareDataWithMedic) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(APIConstants.changeSharingPreferenceStatusUrl)
        .replace(queryParameters: {
      'share_data_with_medic': shareDataWithMedic.toString(),
    });
    final response =
        await APIClient.patch(uri.toString(), null, headers: headers);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to change sharing preference: ${response.statusCode}: ${response.body}');
    }
  }

  Future<Medic> getAssignedMedic() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.getAssignedMedicUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get assigned medic: ${response.statusCode}');
    }
    return Medic.fromJson(jsonDecode(response.body));
  }

  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.getAllMedicalRecordsForUserUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch all medical records: ${response.statusCode}: ${response.body}');
    }
    final List<dynamic> medicalRecords =
        jsonDecode(response.body) as List<dynamic>;
    return medicalRecords
        .cast<Map<String, dynamic>>()
        .map((r) => UserMedicalRecord.fromJson(r))
        .toList();
  }

  Future<UserMedicalRecord> getLatestMedicalRecordForUser() async {
    final headers = await _getHeaders();
    final response = await APIClient.get(
      APIConstants.getLatestMedicalRecordForUserUrl,
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch latest medical record: ${response.statusCode}: ${response.body}');
    }
    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }
}