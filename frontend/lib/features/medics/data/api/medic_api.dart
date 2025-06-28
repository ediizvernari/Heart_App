import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/assigned_users.dart';
import '../models/medic.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';

class MedicApi {
  static Future<List<Medic>> getFilteredMedicsByLocation(String? city, String? country) async {
    final response = await ApiClient.get<List<dynamic>>(
      APIConstants.getFilteredMedicsUrl,
      queryParameters: {
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => Medic.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load filtered medics.');
  }

  static Future<List<AssignedUser>> getAssignedUsers() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAssignedPatientsUrl);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => AssignedUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load assigned users.');
  }

  static Future<UserHealthData> getAssignedUserHealthData(int userId) async {
    final url = APIConstants.getPatientHealthDataUrl(userId);
    final response = await ApiClient.get<Map<String, dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      return UserHealthData.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load user health data.');
  }

  static Future<List<UserMedicalRecord>> getAssignedUserAllMedicalRecords(int userId) async {
    final url = APIConstants.getAssignedUserAllMedicalRecordsUrl(userId);
    final response = await ApiClient.get<List<dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => UserMedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load all medical records.');
  }

  static Future<UserMedicalRecord> getLatestMedicalRecord(int userId) async {
    final url = APIConstants.getAssignedUserLatestMedicalRecordUrl(userId);
    final response = await ApiClient.get<Map<String, dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      return UserMedicalRecord.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load latest medical record.');
  }
}
