import '../api/appointment_suggestion_api.dart';
import '../models/appointment_suggestion_model.dart';
import 'appointment_suggestion_repository.dart';

class AppointmentSuggestionRepositoryImpl implements AppointmentSuggestionRepository {
  @override
  Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions() {
    return AppointmentSuggestionApi.getMyAppointmentSuggestions();
  }

  @override
  Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions() {
    return AppointmentSuggestionApi.getMedicAppointmentSuggestions();
  }

  @override
  Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion dto) {
    return AppointmentSuggestionApi.createAppointmentSuggestion(dto);
  }

  @override
  Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int appointmentSuggestionId, String newAppointmentSuggestionStatus) {
    return AppointmentSuggestionApi.updateAppointmentSuggestionStatus(appointmentSuggestionId, newAppointmentSuggestionStatus);
  }
}
