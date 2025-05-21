import 'package:frontend/features/appointments/medic_availabilities/data/models/medic_availability_model.dart';

abstract class MedicAvailabilityRepository {
  Future<List<MedicAvailability>> getMyAvailabilities();
  Future<MedicAvailability> createAvailability(MedicAvailability medicAvailability);
  Future<void> deleteAvailability(int medicavailabilityId);
}