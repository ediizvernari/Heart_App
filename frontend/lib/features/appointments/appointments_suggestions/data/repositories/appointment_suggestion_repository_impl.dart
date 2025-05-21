import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';
import '../api/appointment_suggestion_api.dart';
import '../models/appointment_suggestion_model.dart';
import 'appointment_suggestion_repository.dart';

class AppointmentSuggestionRepositoryImpl implements AppointmentSuggestionRepository{
  @override
  Future<List<AppointmentSuggestion>> getMyAppointmentSuggestions() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');
    
    try {
      return await AppointmentSuggestionApi.getMyAppointmentSuggestions(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<AppointmentSuggestion>> getMedicAppointmentSuggestions() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentSuggestionApi.getMedicAppointmentSuggestions(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<AppointmentSuggestion> createAppointmentSuggestion(AppointmentSuggestion dto) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentSuggestionApi.createAppointmentSuggestion(token, dto);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<AppointmentSuggestion> updateAppointmentSuggestionStatus(int appointmentsuggestionId, String newAppointmentSuggestionStatus) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await AppointmentSuggestionApi.updateAppointmentSuggestionStatus(token, appointmentsuggestionId, newAppointmentSuggestionStatus);
    } on ApiException {
      rethrow;
    }
  }
}