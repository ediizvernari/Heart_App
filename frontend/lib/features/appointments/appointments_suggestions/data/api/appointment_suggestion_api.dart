import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import '../../../../../core/api_constants.dart';
import '../models/appointment_suggestion_model.dart';
import '../../../../../services/api_client.dart';

class AppointmentSuggestionApi {
  static Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions(String token) async {
    final resp = await APIClient.get(
      APIConstants.getAllUsersSuggestionsUrl,
      headers: _authHeaders(token),
    );
    if (resp.statusCode != 200) throw ApiException(resp.statusCode, resp.body);
    return (jsonDecode(resp.body) as List)
        .map((e) => AppointmentSuggestion.fromJson(e))
        .toList();
  }

  static Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions(String token) async {
    final resp = await APIClient.get(
      APIConstants.getAllMedicSuggestionsUrl,
      headers: _authHeaders(token),
    );
    if (resp.statusCode != 200) throw ApiException(resp.statusCode, resp.body);
    return (jsonDecode(resp.body) as List)
        .map((e) => AppointmentSuggestion.fromJson(e))
        .toList();
  }

  static Future<AppointmentSuggestion> createAppointmentSuggestion(
    String token,
    AppointmentSuggestion appointmentSuggestion,
  ) async {
    final resp = await APIClient.post(
      APIConstants.appointmentSuggestionForUser(appointmentSuggestion.userId),
      appointmentSuggestion.toJsonForCreate(),
      headers: _authHeaders(token),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException(resp.statusCode, resp.body);
    }
    return AppointmentSuggestion.fromJson(jsonDecode(resp.body));
  }

  static Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(
    String token,
    int id,
    String newStatus,
  ) async {
    final url = APIConstants.changeAppointmentSuggestionStatusUrl(id, newStatus);

    final resp = await APIClient.patch(
      url,
      {},
      headers: _authHeaders(token),
    );

    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, resp.body);
    }
    return AppointmentSuggestion.fromJson(jsonDecode(resp.body));
  }

  //TODO: Use this as an example for the rest of the api's
  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}