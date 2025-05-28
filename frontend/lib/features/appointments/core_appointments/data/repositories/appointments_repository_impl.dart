import 'package:frontend/services/api_exception.dart';
import '../api/appointment_api.dart';
import '../models/appointment_model.dart';
import 'appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentRepository {
  @override
  Future<Appointment> createAppointment(Appointment dto) async {
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
  Future<Appointment> updateAppointmentStatus({required int appointmentId, required String newAppointmentStatus}) async {
    try {
      return await AppointmentApi.updateAppointmentStatus(appointmentId, newAppointmentStatus);
    } on ApiException {
      rethrow;
    }
  }
}