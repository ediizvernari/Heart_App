import 'package:flutter/material.dart';
import 'package:frontend/features/users/data/repositories/user_repository.dart';
import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/assignment_status.dart';

class UserController extends ChangeNotifier {
  final UserRepository _userRepository;

  UserController(this._userRepository);

  bool _hasMedic = false;
  AssignmentStatus? _assignmentStatus;
  Medic? _assignedMedic;
  bool _isLoading = false;
  String? _error;

  bool get hasMedic => _hasMedic;
  AssignmentStatus? get assignmentStatus => _assignmentStatus;
  Medic? get assignedMedic => _assignedMedic;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _wrap(Future<void> Function() fn) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      await fn();
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkUserHasMedic() async => _wrap(() async {
    _hasMedic = await _userRepository.checkUserHasMedic();
  });

  Future<void> getMyAssignmentStatus() async => _wrap(() async {
    _assignmentStatus = await _userRepository.getMyAssignmentStatus();
  });

  Future<void> getMyAssignedMedic() async => _wrap(() async {
    _assignedMedic = await _userRepository.getMyAssignedMedic();
  });

  Future<void> assignMedic(int id) async => _wrap(() async {
    await _userRepository.assignMedic(id);
    _hasMedic = true;
    await getMyAssignmentStatus();
    await getMyAssignedMedic();
  });

  Future<void> unassignMedic() async => _wrap(() async {
    await _userRepository.unassignMedic();
    await getMyAssignmentStatus();
    _assignedMedic = null;
  });

  Future<void> changeSharing(bool newSharingPreference) async => _wrap(() async {
    await _userRepository.changeSharingPreferenceStatus(newSharingPreference);
    await getMyAssignmentStatus();
  });

  void clearError() {
    _error = null;
    notifyListeners();
  }
}