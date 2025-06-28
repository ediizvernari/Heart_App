import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/appointment_suggestion_model.dart';

class AppointmentSuggestionApi {
  static Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAllUsersSuggestionsUrl);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => AppointmentSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load appointment suggestions.');
  }

  static Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getAllMedicSuggestionsUrl);
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => AppointmentSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    
    }
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medic appointment suggestions.');
  }

  static Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion suggestion) async {
    final response = await ApiClient.post<Map<String, dynamic>>(APIConstants.appointmentSuggestionForUser(suggestion.userId), suggestion.toJsonForCreate());
    
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return AppointmentSuggestion.fromJson(response.data!);
    
    }
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create appointment suggestion.');
  }

  static Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int suggestionId, String newStatus) async {
    final url = APIConstants.changeAppointmentSuggestionStatusUrl(suggestionId, newStatus);
    final response = await ApiClient.patch<Map<String, dynamic>>(url, {});
    
    if (response.statusCode == 200 && response.data != null) {
      return AppointmentSuggestion.fromJson(response.data!);
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to update appointment suggestion status.');
  }
}
