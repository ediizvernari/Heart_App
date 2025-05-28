import 'package:frontend/features/appointments/medic_availabilities/data/api/medic_availability_api.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/models/medic_availability_model.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/repositories/medic_availability_repository.dart';
import 'package:frontend/services/api_exception.dart';

class MedicAvailabilityRepositoryImpl implements MedicAvailabilityRepository{
  @override
  Future<List<MedicAvailability>> getMyAvailabilities() async {
    try {
      return await MedicAvailabilityApi.getMyAvailabilities();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicAvailability> createAvailability(MedicAvailability medicAvailability) async {
    try {
      return await MedicAvailabilityApi.createAvailability(medicAvailability);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAvailability (int medicavailabilityId) async {
    try {
      await MedicAvailabilityApi.deleteAvailability(medicavailabilityId);
    } on ApiException {
      rethrow;
    }
  }
}