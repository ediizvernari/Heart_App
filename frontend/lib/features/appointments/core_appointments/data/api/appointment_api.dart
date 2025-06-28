import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_request.dart';
import '../models/appointment_model.dart';

class AppointmentApi {
  static Future<List<Appointment>> getMyAppointments() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAllUserAppointmentsUrl);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load user appointments.');
  }

  static Future<List<Appointment>> getMedicAppointments() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicAppointmentsUrl);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medic appointments.');
  }

  static Future<Appointment> createAppointment(AppointmentRequest appointment) async {
    final response = await ApiClient.post<Map<String, dynamic>>(APIConstants.bookAppointmentUrl, appointment.toJson());
    
    if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
      return Appointment.fromJson(response.data!);
    
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create appointment.');
  }

  static Future<Appointment> updateAppointmentStatus(int appointmentId, String newStatus) async {
    final url = APIConstants.changeAppointmentStatusUrl(appointmentId, newStatus);
    final response = await ApiClient.patch<Map<String, dynamic>>(url, {});
    
    if (response.statusCode == 200 && response.data != null) {
      return Appointment.fromJson(response.data!);
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to update appointment status.');
  }
}
