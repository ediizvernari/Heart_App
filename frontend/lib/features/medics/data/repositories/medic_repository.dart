import 'package:frontend/features/medics/data/models/assigned_users.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_medical_records/data/models/user_medical_record.dart';
import '../models/medic.dart';

abstract class MedicRepository {
  Future<List<Medic>> getFilteredMedicsByLocation(String? city, String? country);
  Future<List<AssignedUser>> getAssignedUsers();
  Future<UserHealthData> getAssignedUserHealthData(int userId);
  Future<List<UserMedicalRecord>> getAssignedUserAllMedicalRecords(int userId);
  Future<UserMedicalRecord?> getAssignedUserLastMedicalRecord(int userId);
}