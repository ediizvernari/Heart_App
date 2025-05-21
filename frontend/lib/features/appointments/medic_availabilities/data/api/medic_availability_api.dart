import 'dart:convert';

import 'package:frontend/services/api_exception.dart';
import '../../../../../core/api_constants.dart';
import '../models/medic_availability_model.dart';
import '../../../../../services/api_client.dart';

class MedicAvailabilityApi {
  static Future<List<MedicAvailability>> getMyAvailabilities(String token) async {
    const url = APIConstants.getMyAvailabilitiesUrl;
    final response = await APIClient.get(url, headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => MedicAvailability.fromJson(e)).toList();
  }

  static Future<MedicAvailability> createAvailability(String token, MedicAvailability slot) async {
    const url = APIConstants.createMyAvailabilityUrl;
    final response = await APIClient.post(url, slot.toJsonForCreate(), headers: _authHeaders(token));
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return MedicAvailability.fromJson(jsonDecode(response.body));
  }

  static Future<void> deleteAvailability(String token, int slotId) async {
    final url = APIConstants.deleteMyAvailabilityUrl(slotId);
    final response = await APIClient.delete(url, {}, headers: _authHeaders(token));
    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}