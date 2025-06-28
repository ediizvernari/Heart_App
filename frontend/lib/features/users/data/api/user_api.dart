import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/assignment_status.dart';

class UserApi {
  static Future<bool> checkUserHasMedic() async {
    final response = await ApiClient.get<Map<String, dynamic>>(APIConstants.userHasMedicUrl);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!['has_medic'] as bool;
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to check medic assignment status.');
  }

  static Future<AssignmentStatus> getAssignmentStatus() async {
    final response = await ApiClient.get<Map<String, dynamic>>(APIConstants.assignmentStatusUrl);

    if (response.statusCode == 200 && response.data != null) {
      return AssignmentStatus.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to get assignment status.');
  }

  static Future<void> assignMedic(int medicId) async {
    final response = await ApiClient.post<void>(APIConstants.assignMedicUrl, {'medic_id': medicId});

    if (response.statusCode == 200) return;

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to assign medic.');
  }

  static Future<void> unassignMedic() async {
    final response = await ApiClient.get<void>(APIConstants.unassignMedicUrl);

    if (response.statusCode == 200) return;

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to unassign medic.');
  }

  static Future<Medic> getAssignedMedic() async {
    final response = await ApiClient.get<Map<String, dynamic>>(APIConstants.getAssignedMedicUrl);

    if (response.statusCode == 200 && response.data != null) {
      return Medic.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load assigned medic.');
  }
}
