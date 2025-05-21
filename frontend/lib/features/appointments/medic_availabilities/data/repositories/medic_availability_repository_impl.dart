import 'package:frontend/features/appointments/medic_availabilities/data/api/medic_availability_api.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/models/medic_availability_model.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/repositories/medic_availability_repository.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';

class MedicAvailabilityRepositoryImpl implements MedicAvailabilityRepository{
  @override
  Future<List<MedicAvailability>> getMyAvailabilities() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicAvailabilityApi.getMyAvailabilities(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicAvailability> createAvailability(MedicAvailability medicAvailability) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicAvailabilityApi.createAvailability(token, medicAvailability);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAvailability (int medicavailabilityId) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      await MedicAvailabilityApi.deleteAvailability(token, medicavailabilityId);
    } on ApiException {
      rethrow;
    }
  }
}