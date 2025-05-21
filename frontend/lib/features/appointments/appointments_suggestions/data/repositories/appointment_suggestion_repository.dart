import '../models/appointment_suggestion_model.dart';

abstract class AppointmentSuggestionRepository {
  Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions();
  Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions();
  Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion dto);
  Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int appointmentSuggestionID, String newAppointmentSuggestionStatus);
}