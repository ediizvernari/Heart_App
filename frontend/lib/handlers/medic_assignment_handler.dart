import 'package:frontend/features/users/presentation/controllers/user_controller.dart';

class MedicAssignmentHandler {
  final UserController _userController;
  MedicAssignmentHandler(this._userController);

  Future<void> assignMedic(int medicId) {
  return _userController.assignMedic(medicId);
}
}