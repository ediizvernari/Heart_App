import '../services/user_service.dart';

class MedicAssignmentHandler {
  final UserService _userService;

  MedicAssignmentHandler(this._userService);

  Future<void> assignMedic(int medicId) async {
    await _userService.assignMedic(medicId);
  }
}
