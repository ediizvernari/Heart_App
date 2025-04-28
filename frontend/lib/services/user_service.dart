import 'dart:convert';
import 'package:frontend/models/medic.dart';
import 'package:frontend/models/user_medical_record.dart';
import '../core/api_constants.dart';
import 'api_client.dart';

//TODO: Change the names across the entire frontend to either get or fetch
class UserService {
  final String _token;
  late final Map<String, String> _headers;

  UserService(this._token) {
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_token',
    };
  }

  Future<bool> checkUserHasMedic() async {
    final response = await APIClient.get(
      APIConstants.userHasMedicUrl,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check if user has medic: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['has_medic'] as bool;
  }
  
  Future <Map<String, dynamic>> getAssignmentStatus() async {
    final response = await APIClient.get(
      APIConstants.assignmentStatusUrl,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get assignment status: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> assignMedic(int medicId) async {
    final response = await APIClient.post(
      APIConstants.assignMedicUrl,
      {'medic_id': medicId},
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign medic: ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> unassignMedic() async {
    final response = await APIClient.get(APIConstants.unassignMedicUrl, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to unassign medic: ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> changeSharingPreferenceStatus(bool shareDataPreferences) async {
    final uri = Uri.parse(APIConstants.changeSharingPreferenceStatusUrl)
        .replace(queryParameters: {'share_data_with_medic': shareDataPreferences.toString()});

    final response = await APIClient.patch(uri.toString(), null, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to change sharing preference: ${response.statusCode}: ${response.body}');
    }
  }

  Future<Medic> getAssignedMedic() async {
    final response = await APIClient.get(APIConstants.getAssignedMedicUrl, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get assigned medic: ${response.statusCode}');
    }

    return Medic.fromJson(jsonDecode(response.body));
  }

  Future<List<UserMedicalRecord>> getAllMedicalRecordsForUser() async {
    final response = await APIClient.get(APIConstants.getAllMedicalRecordsForUserUrl, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch all medical records: ${response.statusCode}: ${response.body}');
    }

    final List<dynamic> medicalRecords = jsonDecode(response.body) as List<dynamic>;
    return medicalRecords.cast<Map<String, dynamic>>()
        .map((record) => UserMedicalRecord.fromJson(record))
        .toList();
  }

  Future<UserMedicalRecord> getLatestMedicalRecordForUser() async {
    final response = await APIClient.get(APIConstants.getLatestMedicalRecordForUserUrl, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch latest medical record: ${response.statusCode}: ${response.body}');
    }

    return UserMedicalRecord.fromJson(jsonDecode(response.body));
  }
}