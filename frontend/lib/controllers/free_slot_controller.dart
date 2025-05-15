import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../services/schedule_api.dart';
import '../utils/auth_store.dart';

class FreeSlotController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<TimeSlot> freeSlots = [];

  Future<void> loadFreeTimeSlotsForMedic({
    required int medicId,
    required String isoDate,
    required int durationMinutes,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final token = await AuthStore.getToken();
      if (token == null) throw Exception('Not authenticated');
      freeSlots = await ScheduleApi.getFreeSlotsForMedic(
        token, medicId, isoDate, durationMinutes,
      );
    } catch (e) {
      errorMessage = e.toString();
      freeSlots = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFreeTimeSlotsForAssignedMedic({
    required String isoDate,
    int? medicalServiceId,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final token = await AuthStore.getToken();
      if (token == null) throw Exception('Not authenticated');
      freeSlots = await ScheduleApi.getFreeSlotsForAssignedMedic(
        token, isoDate, medicalServiceId: medicalServiceId,
      );
    } catch (e) {
      errorMessage = e.toString();
      freeSlots = [];
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    freeSlots = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }
}
