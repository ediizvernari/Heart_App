import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';

abstract class ScheduleRepository {
  Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String isoDate, int? medicalServiceId);
}