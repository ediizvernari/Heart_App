import 'package:dio/dio.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/user_health_data_model.dart';

class UserHealthDataApi {
  static Future<bool> checkUserHasHealthData() async {
    try {
      final Response<dynamic> response = await ApiClient.get<dynamic>(APIConstants.checkUserHasHealthDataUrl);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is bool) return data;
        if (data is String) return data.toLowerCase() == 'true';
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to check user health data existence.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<UserHealthData> upsertUserHealthData(UserHealthData dto) async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.post<Map<String, dynamic>>(APIConstants.upsertUserHealthDataUrl, dto.toJsonForCreate());

      if (response.statusCode == 200 && response.data != null) {
        return UserHealthData.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to upsert user health data.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }

  static Future<UserHealthData> getUserHealthDataForPrediction() async {
    try {
      final Response<Map<String, dynamic>> response = await ApiClient.get<Map<String, dynamic>>(APIConstants.fetchUserHealthDataForUserUrl);

      if (response.statusCode == 200 && response.data != null) {
        return UserHealthData.fromJson(response.data!);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to fetch user health data for prediction.');
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode ?? -1;
      final message = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, message!);
    }
  }
}