import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/medic_availability_model.dart';

class MedicAvailabilityApi {
  static Future<List<MedicAvailability>> getMyAvailabilities() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getMyAvailabilitiesUrl);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((e) => MedicAvailability.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load availability slots.');
  }

  static Future<MedicAvailability> createAvailability(MedicAvailability slot) async {
    final response = await ApiClient.post<Map<String, dynamic>>(APIConstants.createMyAvailabilityUrl, slot.toJsonForCreate());
    
    if (response.statusCode == 200 && response.data != null) {
      return MedicAvailability.fromJson(response.data!);
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create availability slot.');
  }

  static Future<void> deleteAvailability(int slotId) async {
    final url = APIConstants.deleteMyAvailabilityUrl(slotId);
    final response = await ApiClient.delete<void>(url);
    
    if (response.statusCode == 204) {
      return;
    }
    
    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to delete availability slot.');
  }
}