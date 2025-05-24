import 'dart:convert';
import 'package:frontend/features/cvd_prediction/data/models/prediction_result.dart';
import 'package:frontend/services/api_exception.dart';

import '../../../../services/api_client.dart';
import '../../../../core/api_constants.dart';

class CvdPredictionApi {
  static Future<PredictionResult> getCVDPredictionPercentage(String? token) async {
    final response = await APIClient.get(
      APIConstants.checkCvdPredictionUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return PredictionResult.fromJson(jsonData);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
}