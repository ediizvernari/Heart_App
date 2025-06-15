import 'package:frontend/features/medics/data/models/medic.dart';
import '../models/assignment_status.dart';

abstract class UserRepository {
  Future<bool> checkUserHasMedic();
  Future<AssignmentStatus> getMyAssignmentStatus();
  Future<void> assignMedic(int medicId);
  Future<void> unassignMedic();
  Future<Medic> getMyAssignedMedic();
}