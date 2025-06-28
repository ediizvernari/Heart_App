import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';
import 'package:frontend/features/appointments/scheduling/data/repositories/schedule_repository.dart';
import 'package:frontend/core/network/api_exception.dart';

class MedicScheduleController extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository;

  MedicScheduleController(this._scheduleRepository);

  List<TimeSlot> freeTimeSlots = [];
  bool isLoading = false;
  String? error;

  Future<void> getFreeTimeSlotsForAssignedMedic({required String targetDate, int? medicalServiceId}) async {
    _setLoading(true);

    try {
      freeTimeSlots = await _scheduleRepository.getFreeSlotsForAssignedMedic(targetDate, medicalServiceId);
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    isLoading = v;
    if (v) error = null;
    notifyListeners();
  }

  void clear() {
    freeTimeSlots = [];
    error = null;
    notifyListeners();
  }
}
