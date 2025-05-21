import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/appointment_suggestion_model.dart';
import '../../data/repositories/appointment_suggestion_repository.dart';

class UserAppointmentSuggestionController extends ChangeNotifier {
  final AppointmentSuggestionRepository _appointmentSuggestionRepository;

  UserAppointmentSuggestionController(this._appointmentSuggestionRepository);

  List<AppointmentSuggestion> myAppointmentSuggestions = [];
  bool isLoading = false;
  String? error;
  
  Future<void> getMyAppointmentSuggestions() async {
    _setLoading(true);
    try {
      myAppointmentSuggestions = await _appointmentSuggestionRepository.getMyAppointmentSuggestions();
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> respondToSuggestion(int appointmentSuggestionId, String newStatus) async {
    _setLoading(true);

    try {
      final updatedAppointmentSuggestion = await _appointmentSuggestionRepository.updateAppointmentSuggestionStatus(appointmentSuggestionId, newStatus); 

      final idx = myAppointmentSuggestions.indexWhere((s) => s.id == appointmentSuggestionId);
      if (idx != -1) myAppointmentSuggestions[idx] = updatedAppointmentSuggestion;
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool v) {
    isLoading = v;
    if (v) error = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
