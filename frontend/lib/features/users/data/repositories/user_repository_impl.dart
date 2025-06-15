import 'package:frontend/features/medics/data/models/medic.dart';
import '../api/user_api.dart';
import '../models/assignment_status.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<bool> checkUserHasMedic() async => 
    UserApi.checkUserHasMedic();

  @override
  Future<AssignmentStatus> getMyAssignmentStatus() async => 
    UserApi.getAssignmentStatus();

  @override
  Future<void> assignMedic(int medicId) async => 
    UserApi.assignMedic(medicId);

  @override
  Future<void> unassignMedic() async =>
    UserApi.unassignMedic();

  @override
  Future<Medic> getMyAssignedMedic() async =>
    UserApi.getAssignedMedic();
}