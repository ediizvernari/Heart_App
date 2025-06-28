import 'package:frontend/features/appointments/core_appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_request.dart';

abstract class AppointmentRepository{
  Future<Appointment> createAppointment(AppointmentRequest dto);
  Future<List<Appointment>> getUserAppointments();
  Future<List<Appointment>> getMedicAppointments();
  Future<Appointment> updateAppointmentStatus(int appointmentId, String newAppointmentStatus);
}