import 'dart:convert';
import 'package:frontend/features/users/data/models/assignment_status.dart';
import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:frontend/services/api_exception.dart';
import '../../../../core/api_constants.dart';
import '../../../../services/api_client.dart';

class UserApi {
  static Map<String,String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  static Future<bool> checkUserHasMedic(String token) async {
    final response = await APIClient.get(
      APIConstants.userHasMedicUrl,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['has_medic'] as bool;
  }

  static Future<AssignmentStatus> getAssignmentStatus(String token) async {
    final response = await APIClient.get(
      APIConstants.assignmentStatusUrl,
      headers: _authHeaders(token),
    );
    
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return AssignmentStatus.fromJson(jsonDecode(response.body));
  }

  static Future<void> assignMedic(String token, int medicId) async {
    final response = await APIClient.post(
      APIConstants.assignMedicUrl,
      {'medic_id': medicId},
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<void> unassignMedic(String token) async {
    final response = await APIClient.get(
      APIConstants.unassignMedicUrl,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<void> changeSharingPreferenceStatus(String token, bool share) async {
    final uri = Uri.parse(APIConstants.changeSharingPreferenceStatusUrl)
      .replace(queryParameters: {'share_data_with_medic': share.toString()});
    
    final response = await APIClient.patch(
      uri.toString(), null,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<Medic> getAssignedMedic(String token) async {
    final response = await APIClient.get(
      APIConstants.getAssignedMedicUrl,
      headers: _authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return Medic.fromJson(jsonDecode(response.body));
  }
}