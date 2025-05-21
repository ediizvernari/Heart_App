import 'package:frontend/features/appointments/scheduling/data/api/schedule_api.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';

class ScheduleRepositoryImpl implements ScheduleRepository{
  @override
  Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String isoDate, int? medicalServiceId) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await ScheduleApi.getFreeSlotsForAssignedMedic(token, isoDate, medicalServiceId);
    } on ApiException {
      rethrow;
    }
  }
}