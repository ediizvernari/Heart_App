import 'package:dio/dio.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentApi {
  static Future<List<Appointment>> getMyAppointments() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getAllUserAppointmentsUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load user appointments.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<List<Appointment>> getMedicAppointments() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicAppointmentsUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medic appointments.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.post<Map<String, dynamic>>(APIConstants.bookAppointmentUrl, appointment.toJsonForCreate());

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return Appointment.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create appointment.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<Appointment> updateAppointmentStatus(int appointmentId, String newStatus) async {
    final String url = APIConstants.changeAppointmentStatusUrl(appointmentId, newStatus);

    try {
      final Response<Map<String, dynamic>> response = await ApiClient.patch<Map<String, dynamic>>(url, {});

      if (response.statusCode == 200 && response.data != null) {
        return Appointment.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to update appointment status.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }
}
