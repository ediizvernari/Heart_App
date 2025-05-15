import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import '../core/api_constants.dart';
import '../models/appointment_suggestion.dart';
import 'api_client.dart';

class AppointmentSuggestionApi {
  static Future<List<AppointmentSuggestion>> getMySuggestions(String token) async {
    final resp = await APIClient.get(
      APIConstants.getAllUsersSuggestionsUrl,
      headers: _authHeaders(token),
    );
    if (resp.statusCode != 200) throw ApiException(resp.statusCode, resp.body);
    return (jsonDecode(resp.body) as List)
        .map((e) => AppointmentSuggestion.fromJson(e))
        .toList();
  }

  static Future<List<AppointmentSuggestion>> getMedicSuggestions(String token) async {
    final resp = await APIClient.get(
      APIConstants.getAllMedicSuggestionsUrl,
      headers: _authHeaders(token),
    );
    if (resp.statusCode != 200) throw ApiException(resp.statusCode, resp.body);
    return (jsonDecode(resp.body) as List)
        .map((e) => AppointmentSuggestion.fromJson(e))
        .toList();
  }

  static Future<AppointmentSuggestion> createSuggestion(
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

  static Future<AppointmentSuggestion> updateSuggestionStatus(
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

  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}