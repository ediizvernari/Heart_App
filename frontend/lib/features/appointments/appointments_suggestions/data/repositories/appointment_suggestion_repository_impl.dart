import 'package:frontend/services/api_exception.dart';
import '../api/appointment_suggestion_api.dart';
import '../models/appointment_suggestion_model.dart';
import 'appointment_suggestion_repository.dart';

class AppointmentSuggestionRepositoryImpl implements AppointmentSuggestionRepository{
  @override
  Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions() async { 
    try {
      return await AppointmentSuggestionApi.getMyAppointmentSuggestions();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions() async {
    try {
      return await AppointmentSuggestionApi.getMedicAppointmentSuggestions();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion dto) async {
    try {
      return await AppointmentSuggestionApi.createAppointmentSuggestion(dto);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int appointmentsuggestionId, String newAppointmentSuggestionStatus) async {
    try {
      return await AppointmentSuggestionApi.updateAppointmentSuggestionStatus(appointmentsuggestionId, newAppointmentSuggestionStatus);
    } on ApiException {
      rethrow;
    }
  }
}