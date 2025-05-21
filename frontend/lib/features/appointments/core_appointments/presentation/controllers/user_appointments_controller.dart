import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointments_repository.dart';

class UserAppointmentsController extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  UserAppointmentsController(this._appointmentRepository);

  List<Appointment> myAppointments = [];
  bool isLoading = false;
  String? error;

  Future<void> getMyAppointments() async {
    _setLoading(true);
    
    try {
      myAppointments = await _appointmentRepository.getUserAppointments();
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    _setLoading(true);

    try {
      final createdAppointment = await _appointmentRepository.createAppointment(appointment);
      myAppointments.add(createdAppointment);
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
