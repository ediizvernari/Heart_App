import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/prediction_result.dart';

class CvdPredictionApi {
  static Future<PredictionResult> getCvdPredictionPercentage() async {
    try {
      final Response<dynamic> response = await ApiClient.get<dynamic>(APIConstants.checkCvdPredictionUrl);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonData = response.data is String
            ? json.decode(response.data as String)
            : response.data as Map<String, dynamic>;
        return PredictionResult.fromJson(jsonData);
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Unknown error fetching CVD prediction.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }
}
