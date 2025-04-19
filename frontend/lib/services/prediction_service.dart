import 'dart:convert';
import 'api_client.dart';
import '../core/api_constants.dart';

class PredictionService {
  static Future<double> getCVDPredictionPercentage(String? token) async {
    final response = await APIClient.get(
      APIConstants.checkCvdPredictionUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return (body['prediction'] as num).toDouble();
    } else {
      throw Exception("Failed to fetch CVD prediction: ${response.body}");
    }
  }
}