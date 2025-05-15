import 'package:flutter/material.dart';

import '../models/appointment_suggestion.dart';
import '../services/appointment_suggestion_api.dart';
import '../utils/auth_store.dart';
import '../services/api_exception.dart';

class MedicAppointmentSuggestionController extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<AppointmentSuggestion> sentSuggestions = [];

  Future<void> loadSentSuggestions() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      sentSuggestions =
          await AppointmentSuggestionApi.getMedicSuggestions(token);
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createSuggestion(AppointmentSuggestion suggestion) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      final created = await AppointmentSuggestionApi.createSuggestion(
        token,
        suggestion,
      );
      sentSuggestions.add(created);
    } catch (e) {
      if (e is ApiException) {
        error = 'Error ${e.statusCode}: ${e.responseBody}';
      } else {
        error = e.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
