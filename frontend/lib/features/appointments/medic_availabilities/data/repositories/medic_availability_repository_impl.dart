import 'package:frontend/features/appointments/medic_availabilities/data/api/medic_availability_api.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/models/medic_availability_model.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/repositories/medic_availability_repository.dart';

class MedicAvailabilityRepositoryImpl implements MedicAvailabilityRepository {
  @override
  Future<List<MedicAvailability>> getMyAvailabilities() {
    return MedicAvailabilityApi.getMyAvailabilities();
  }

  @override
  Future<MedicAvailability> createAvailability(MedicAvailability medicAvailability) {
    return MedicAvailabilityApi.createAvailability(medicAvailability);
  }

  @override
  Future<void> deleteAvailability(int medicAvailabilityId) {
    return MedicAvailabilityApi.deleteAvailability(medicAvailabilityId);
  }
}