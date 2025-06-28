import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_request.dart';
import '../api/appointment_api.dart';
import '../models/appointment_model.dart';
import 'appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentRepository {
  @override
  Future<Appointment> createAppointment(AppointmentRequest dto) async {
    try {
      return await AppointmentApi.createAppointment(dto);
    } on ApiException {
      rethrow;
    }
  }
  
  @override
  Future<List<Appointment>> getUserAppointments() async {
    try {
      return await AppointmentApi.getMyAppointments();
    } on ApiException {
      rethrow;
    }
  }
  
  @override
  Future<List<Appointment>> getMedicAppointments() async {
    try {
      return await AppointmentApi.getMedicAppointments();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<Appointment> updateAppointmentStatus(int appointmentId, String newAppointmentStatus) async {
    try {
      return await AppointmentApi.updateAppointmentStatus(appointmentId, newAppointmentStatus);
    } on ApiException {
      rethrow;
    }
  }
}