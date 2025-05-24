import 'package:frontend/features/medics/data/models/assigned_users.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';
import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/services/api_exception.dart';
import '../api/medic_api.dart';
import '../models/medic.dart';
import 'medic_repository.dart';

class MedicRepositoryImpl implements MedicRepository {
  Future<String> _token() async {
    final String? token = await AuthStore.getToken();

    if (token == null) {
      throw ApiException(401, 'Unauthorized: No token found');
    }

    return token;
  }

  @override
  Future<List<Medic>> getFilteredMedicsByLocation(String? city, String? country) async {
    final token = await _token();
    return MedicApi.getFilteredMedicsByLocation(city, country, token);
  }

  @override
  Future<List<AssignedUser>> getAssignedUsers() async {
    final token = await _token();
    return MedicApi.getAssignedUsers(token);
  }

  @override
  Future<UserHealthData> getAssignedUserHealthData(int userId) async {
    final token = await _token();
    return MedicApi.getAssignedUserHealthData(token, userId);
  }

  @override
  Future<List<UserMedicalRecord>> getAssignedUserAllMedicalRecords(int userId) async {
    final token = await _token();
    return MedicApi.getAssignedUserAllMedicalRecords(token, userId);
  }

  @override
  Future<UserMedicalRecord?> getAssignedUserLastMedicalRecord(int userId) async {
    final token = await _token();
    try {
      return await MedicApi.getLatestMedicalRecord(token, userId);
    } catch (e) {
      return null;
    }
  }
}