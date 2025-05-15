import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/appointment_api.dart';
import '../utils/auth_store.dart';
import '../services/api_exception.dart';

class AppointmentController extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<Appointment> myAppointments = [];
  List<Appointment> medicAppointments = [];

  Future<void> loadMyAppointments() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      myAppointments = await AppointmentAPI.getMyAppointments(token);
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicAppointments() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      medicAppointments = await AppointmentAPI.getMedicAppointments(token);
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      final created = await AppointmentAPI.createAppointment(token, appointment);
      myAppointments.add(created);
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(int appointmentId, String newStatus) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      final updated = await AppointmentAPI.updateAppointmentStatus(
        token,
        appointmentId,
        newStatus,
      );

      final idx = medicAppointments.indexWhere((a) => a.id == appointmentId);
      if (idx != -1) {
        medicAppointments[idx] = updated;
      }
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
