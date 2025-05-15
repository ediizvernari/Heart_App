import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import '../core/api_constants.dart';
import '../models/time_slot.dart';
import 'api_client.dart';

class ScheduleApi {
  static Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  static Future<List<TimeSlot>> getFreeSlotsForMedic(String token, int medicId, String isoDate, int durationMinutes) async {
    final url = Uri.parse(APIConstants.medicFreeSlotsUrl).replace(
      queryParameters: {
        'target_date': isoDate,
        'time_slot_duration_minutes': durationMinutes.toString(),
      },
    ).toString();
    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => TimeSlot.fromJson(e)).toList();
  }

  static Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String token, String isoDate, {int? medicalServiceId}) async {
    final params = {'target_date': isoDate};
    if (medicalServiceId != null) {
      params['medical_service_id'] = medicalServiceId.toString();
    }
    final url = Uri.parse(APIConstants.myAssignedMedicFreeTimeSlots)
        .replace(queryParameters: params)
        .toString();
    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => TimeSlot.fromJson(e)).toList();
  }
}