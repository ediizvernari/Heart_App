import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_request.dart';
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
    }
  }

  Future<void> createAppointment(AppointmentRequest appointment) async {
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

  Future<void> updateAppointmentStatus(int appointmentId, String newAppointmentStatus) async {
    _setLoading(true);

    try {
      final updatedAppointment = await _appointmentRepository.updateAppointmentStatus(appointmentId, newAppointmentStatus);
      final appointmentIndex = myAppointments.indexWhere((a) => a.id == appointmentId);
      
      if (appointmentIndex != -1) myAppointments[appointmentIndex] = updatedAppointment;
      
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
