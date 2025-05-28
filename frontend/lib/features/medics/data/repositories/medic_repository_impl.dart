import 'package:frontend/features/medics/data/models/assigned_users.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';
import '../api/medic_api.dart';
import '../models/medic.dart';
import 'medic_repository.dart';

class MedicRepositoryImpl implements MedicRepository {
  @override
  Future<List<Medic>> getFilteredMedicsByLocation(String? city, String? country) async {
    return MedicApi.getFilteredMedicsByLocation(city, country);
  }

  @override
  Future<List<AssignedUser>> getAssignedUsers() async {
    return MedicApi.getAssignedUsers();
  }

  @override
  Future<UserHealthData> getAssignedUserHealthData(int userId) async {
    return MedicApi.getAssignedUserHealthData(userId);
  }

  @override
  Future<List<UserMedicalRecord>> getAssignedUserAllMedicalRecords(int userId) async {
    return MedicApi.getAssignedUserAllMedicalRecords(userId);
  }

  @override
  Future<UserMedicalRecord?> getAssignedUserLastMedicalRecord(int userId) async {
    try {
      return await MedicApi.getLatestMedicalRecord(userId);
    } catch (e) {
      return null;
    }
  }
}