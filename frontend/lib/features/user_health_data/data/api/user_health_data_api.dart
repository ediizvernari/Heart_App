import 'dart:convert';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/services/api_exception.dart';

import '../../../../services/api_client.dart';
import '../../../../core/api_constants.dart';

class UserHealthDataApi {
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
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<UserHealthData> upsertUserHealthData(String token, UserHealthData dto) async {
    final response = await APIClient.post(
      APIConstants.upsertUserHealthDataUrl,
      dto.toJsonForCreate(),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return UserHealthData.fromJson(jsonData);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<UserHealthData> getUserHealthDataForPrediction(String token) async {
    final response = await APIClient.get(
      APIConstants.fetchUserHealthDataForUserUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserHealthData.fromJson(jsonData);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
}