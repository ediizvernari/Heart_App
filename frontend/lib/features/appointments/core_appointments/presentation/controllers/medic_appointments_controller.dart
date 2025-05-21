import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointments_repository.dart';

class MedicAppointmentsController extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  MedicAppointmentsController(this._appointmentRepository);

  List<Appointment> medicAppointments = [];
  bool isLoading = false;
  String? error;

  Future<void> getMedicAppointments() async {
    _setLoading(true);

    try {
      medicAppointments = await _appointmentRepository.getMedicAppointments();
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }

    print("LoadingState: ${isLoading}");
  }

  Future<void> updateAppointmentStatus(int appointmentId, String newAppointmentStatus) async {
    _setLoading(true);

    try {
      final updatedAppointment = await _appointmentRepository.updateAppointmentStatus(appointmentId: appointmentId, newAppointmentStatus: newAppointmentStatus);
      final appointmentIndex = medicAppointments.indexWhere((a) => a.id == appointmentId);
      
      if (appointmentIndex != -1) medicAppointments[appointmentIndex] = updatedAppointment;
      
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
