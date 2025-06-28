import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/prediction_result.dart';

class CvdPredictionApi {
  static Future<PredictionResult> getCvdPredictionPercentage() async {
    final Response<Map<String, dynamic>> resp = await ApiClient.get<Map<String, dynamic>>(APIConstants.checkCvdPredictionUrl);
      
      if (resp.statusCode == 200 && resp.data != null) {
        return PredictionResult.fromJson(resp.data!);
      }

      throw ApiException(resp.statusCode ?? 0, resp.statusMessage ?? 'Unknown error fetching CVD prediction.');
  }
}