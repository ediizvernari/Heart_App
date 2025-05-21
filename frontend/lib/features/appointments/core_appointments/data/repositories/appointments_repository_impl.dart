import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';
import '../api/appointment_api.dart';
import '../models/appointment_model.dart';
import 'appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentRepository {
  @override
  Future<Appointment> createAppointment(Appointment dto) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentAPI.createAppointment(token, dto);
    } on ApiException {
      rethrow;
    }
  }
  
  @override
  Future<List<Appointment>> getUserAppointments() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentAPI.getMyAppointments(token);
    } on ApiException {
      rethrow;
    }
  }
  
  @override
  Future<List<Appointment>> getMedicAppointments() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentAPI.getMedicAppointments(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<Appointment> updateAppointmentStatus({required int appointmentId, required String newAppointmentStatus}) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentAPI.updateAppointmentStatus(token, appointmentId, newAppointmentStatus);
    } on ApiException {
      rethrow;
    }
  }
}