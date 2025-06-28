import 'package:frontend/features/appointments/scheduling/data/api/schedule_api.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository{
  @override
  Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String targetDate, int? medicalServiceId) async {
    return await ScheduleApi.getFreeSlotsForAssignedMedic(targetDate, medicalServiceId);
  }
}