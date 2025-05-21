import 'package:flutter/material.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/appointment_suggestion_model.dart';
import '../../data/repositories/appointment_suggestion_repository.dart';

class MedicAppointmentSuggestionController extends ChangeNotifier {
  final AppointmentSuggestionRepository _appointmentSuggestionrepository;
  
  MedicAppointmentSuggestionController(this._appointmentSuggestionrepository);

  bool isLoading = false;
  String? error;

  List<AppointmentSuggestion> sentAppointmentSuggestions = [];

  Future<void> getMedicAppointmentSuggestions() async {
    _setLoading(true);

    try {
      sentAppointmentSuggestions = await _appointmentSuggestionrepository.getMedicAppointmentSuggestions();
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createSuggestion(AppointmentSuggestion appointmentSuggestion) async {
    _setLoading(true);

    try {
      AppointmentSuggestion sentAppointmentSuggestion = await _appointmentSuggestionrepository.createAppointmentSuggestion(appointmentSuggestion);
      sentAppointmentSuggestions.add(sentAppointmentSuggestion);
      error = null;
    } on ApiException catch (e) {
      error = e.responseBody;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
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
