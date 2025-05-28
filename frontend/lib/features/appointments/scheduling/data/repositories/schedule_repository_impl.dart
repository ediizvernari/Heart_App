import 'package:frontend/features/appointments/scheduling/data/api/schedule_api.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository.dart';
import 'package:frontend/services/api_exception.dart';

class ScheduleRepositoryImpl implements ScheduleRepository{
  @override
  Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String isoDate, int? medicalServiceId) async {
    try {
      return await ScheduleApi.getFreeSlotsForAssignedMedic(isoDate, medicalServiceId);
    } on ApiException {
      rethrow;
    }
  }
}