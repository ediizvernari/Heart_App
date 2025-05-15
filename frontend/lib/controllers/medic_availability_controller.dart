import 'package:flutter/material.dart';
import '../models/medic_availability.dart';
import '../services/medic_availability_api.dart';
import '../utils/auth_store.dart';

class MedicAvailabilityController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<MedicAvailability> slots = [];

  Future<void> loadMyAvailabilities() async {
    _setLoading(true);
    errorMessage = null;
    try {
      final token = await AuthStore.getToken();
      if (token == null) throw Exception('Not authenticated');
      slots = await MedicAvailabilityApi.getMyAvailabilities(token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAvailability(MedicAvailability slot) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final token = await AuthStore.getToken();
      if (token == null) throw Exception('Not authenticated');
      final created = await MedicAvailabilityApi.createAvailability(token, slot);
      slots.add(created);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeAvailability(int slotId) async {
    _setLoading(true);
    errorMessage = null;
    try {
      final token = await AuthStore.getToken();
      if (token == null) throw Exception('Not authenticated');
      await MedicAvailabilityApi.deleteAvailability(token, slotId);
      slots.removeWhere((s) => s.id == slotId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}