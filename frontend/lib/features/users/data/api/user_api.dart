import 'package:dio/dio.dart';
import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/assignment_status.dart';

class UserApi {
  static Future<bool> checkUserHasMedic() async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(APIConstants.userHasMedicUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!['has_medic'] as bool;
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to check medic assignment status.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<AssignmentStatus> getAssignmentStatus() async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(APIConstants.assignmentStatusUrl);

      if (response.statusCode == 200 && response.data != null) {
        return AssignmentStatus.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to get assignment status.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<void> assignMedic(int medicId) async {
    try {
      final Response<void> response = await ApiClient.post<void>(APIConstants.assignMedicUrl,{'medic_id': medicId});

      if (response.statusCode == 200) return;

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to assign medic.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<void> unassignMedic() async {
    try {
      final Response<void> response = await ApiClient.get<void>(APIConstants.unassignMedicUrl);

      if (response.statusCode == 200) return;
      
      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to unassign medic.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<void> changeSharingPreferenceStatus(bool share) async {
    try {
      final Response<void> response = await ApiClient.patch<void>(APIConstants.changeSharingPreferenceStatusUrl, null, queryParameters: {'share_data_with_medic': share});

      if (response.statusCode == 200) return;
      
      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to change sharing preference.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<Medic> getAssignedMedic() async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(APIConstants.getAssignedMedicUrl);

      if (response.statusCode == 200 && response.data != null) {
        return Medic.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load assigned medic.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }
}
