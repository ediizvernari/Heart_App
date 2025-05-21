import 'package:frontend/features/appointments/core_appointments/data/models/appointment_model.dart';

abstract class AppointmentRepository{
  Future<Appointment> createAppointment(Appointment dto);
  Future<List<Appointment>> getUserAppointments();
  Future<List<Appointment>> getMedicAppointments();
  Future<Appointment> updateAppointmentStatus({required int appointmentId, required String newAppointmentStatus});
}