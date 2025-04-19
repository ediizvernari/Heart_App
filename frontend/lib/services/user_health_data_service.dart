import 'dart:convert';
import 'api_client.dart';
import '../core/api_constants.dart';

class UserHealthDataService {
  static Future<bool> checkUserHasHealthData(String token) async {
    final response = await APIClient.get(
      APIConstants.checkUserHasHealthDataUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.body == 'true';
    } else {
      throw Exception('Failed to check user health data: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserHealthDataForPrediction(String token) async {
    final response = await APIClient.get(
      APIConstants.fetchUserHealthDataForUserUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user health data: ${response.body}');
    }
  }
}