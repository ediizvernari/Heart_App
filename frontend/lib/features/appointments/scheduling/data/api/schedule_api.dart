import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/time_slot_model.dart';

class ScheduleApi {
  static Future<List<TimeSlot>> getFreeSlotsForAssignedMedic(String targetDate, int? medicalServiceId) async {
    final response = await ApiClient.get<List<dynamic>>(
      APIConstants.myAssignedMedicFreeTimeSlots,
      queryParameters: {
        'target_date': targetDate,
        if (medicalServiceId != null) 'medical_service_id': medicalServiceId,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load free time slots.');
  }
}