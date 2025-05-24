import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/services/api_exception.dart';
import '../api/user_api.dart';
import '../models/assignment_status.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  Future<String> _token() async {
    final t = await AuthStore.getToken();
    if (t == null) throw ApiException(401, 'Missing auth token');
    return t;
  }

  @override
  Future<bool> checkUserHasMedic() async => 
    UserApi.checkUserHasMedic(await _token());

  @override
  Future<AssignmentStatus> getMyAssignmentStatus() async => 
    UserApi.getAssignmentStatus(await _token());

  @override
  Future<void> assignMedic(int medicId) async => 
    UserApi.assignMedic(await _token(), medicId);

  @override
  Future<void> unassignMedic() async =>
    UserApi.unassignMedic(await _token());

  @override
  Future<void> changeSharingPreferenceStatus(bool newSharingPreferenceStatus) async =>
    UserApi.changeSharingPreferenceStatus(await _token(), newSharingPreferenceStatus);

  @override
  Future<Medic> getMyAssignedMedic() async =>
    UserApi.getAssignedMedic(await _token());
}