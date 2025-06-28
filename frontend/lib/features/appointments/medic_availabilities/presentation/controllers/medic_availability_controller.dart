import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/models/medic_availability_model.dart';
import 'package:frontend/features/appointments/medic_availabilities/data/repositories/medic_availability_repository.dart';


class MedicAvailabilityController extends ChangeNotifier {
  final MedicAvailabilityRepository _repo;

  MedicAvailabilityController(this._repo);

  bool isLoading = false;
  String? error;
  List<MedicAvailability> medicAvailabilities = [];

  Future<void> getMyAvailabilities() async {
    _setLoading(true);

    try {
      medicAvailabilities = await _repo.getMyAvailabilities();
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAvailability(MedicAvailability slot) async {
    _setLoading(true);

    try {
      final created = await _repo.createAvailability(slot);
      medicAvailabilities.add(created);
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeAvailability(int slotId) async {
    _setLoading(true);
    try {
      await _repo.deleteAvailability(slotId);
      medicAvailabilities.removeWhere((s) => s.id == slotId);
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (value) error = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
