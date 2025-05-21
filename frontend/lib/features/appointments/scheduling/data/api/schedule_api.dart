import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import '../../../../../core/api_constants.dart';
import '../models/time_slot_model.dart';
import '../../../../../services/api_client.dart';

class ScheduleApi {
  static Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String token, String isoDate, int? medicalServiceId) async {
    final queryParameters = {'target_date': isoDate};
    if (medicalServiceId != null) {
      queryParameters['medical_service_id'] = medicalServiceId.toString();
    }
    final url = Uri.parse(APIConstants.myAssignedMedicFreeTimeSlots)
        .replace(queryParameters: queryParameters)
        .toString();
    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => TimeSlot.fromJson(e)).toList();
  }

    static Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}