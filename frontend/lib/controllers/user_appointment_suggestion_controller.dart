import 'package:flutter/material.dart';

import '../models/appointment_suggestion.dart';
import '../services/appointment_suggestion_api.dart';
import '../utils/auth_store.dart';
import '../services/api_exception.dart';

class UserAppointmentSuggestionController extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<AppointmentSuggestion> mySuggestions = [];

  Future<void> loadMySuggestions() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      mySuggestions = await AppointmentSuggestionApi.getMySuggestions(token);
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

  Future<void> respondToSuggestion(int suggestionId, String newStatus) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await AuthStore.getToken();
      if (token == null) throw ApiException(401, 'Not authenticated');

      final updated = await AppointmentSuggestionApi.updateSuggestionStatus(
        token,
        suggestionId,
        newStatus,
      );

      mySuggestions = mySuggestions
          .map((s) => s.id == suggestionId ? updated : s)
          .toList();
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
