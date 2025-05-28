import 'package:dio/dio.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import '../models/appointment_suggestion_model.dart';
import 'package:frontend/core/network/api_client.dart';

class AppointmentSuggestionApi {
  static Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getAllUsersSuggestionsUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => AppointmentSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load appointment suggestions.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicSuggestionsUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => AppointmentSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medic appointment suggestions.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion suggestion) async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.post<Map<String, dynamic>>(APIConstants.appointmentSuggestionForUser(suggestion.userId), suggestion.toJsonForCreate());

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return AppointmentSuggestion.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create appointment suggestion.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int suggestionId, String newStatus) async {
    final String url = APIConstants.changeAppointmentSuggestionStatusUrl(suggestionId, newStatus);

    try {
      final Response<Map<String, dynamic>> response = await ApiClient.patch<Map<String, dynamic>>(url, {});

      if (response.statusCode == 200 && response.data != null) {
        return AppointmentSuggestion.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to update appointment suggestion status.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }
}
