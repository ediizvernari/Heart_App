import 'dart:convert';
import 'package:frontend/services/api_exception.dart';

import '../../../../../services/api_client.dart';
import '../../../../../core/api_constants.dart';
import '../models/appointment_model.dart';

class AppointmentAPI {
  static Future<List<Appointment>> getMyAppointments(String token) async {
    const url = APIConstants.getAllUserAppointmentsUrl;
    final response = await APIClient.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List list = jsonDecode(response.body);
    return list.map((e) => Appointment.fromJson(e)).toList();
  }

  static Future<List<Appointment>> getMedicAppointments(String token) async {
    const url = APIConstants.getAllMedicAppointmentsUrl;
    final response = await APIClient.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List list = jsonDecode(response.body);
    return list.map((e) => Appointment.fromJson(e)).toList();
  }

  static Future<Appointment> createAppointment(String token, Appointment appointment) async {
    const url = APIConstants.bookAppointmentUrl;
    final response = await APIClient.post(
    url,               
    appointment.toJsonForCreate(),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw ApiException(response.statusCode, response.body);
  }

  static Future<Appointment> updateAppointmentStatus(String token, int appointmentId, String newStatus) async {
    final url = APIConstants.changeAppointmentStatusUrl(appointmentId, newStatus);
    final response = await APIClient.patch(
      url,
      {},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Appointment.fromJson(jsonDecode(response.body));
  }
}
