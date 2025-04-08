import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> checkUserHasHealthData(String? token) async {
  final response = await http.get(
    Uri.parse('https://10.0.2.2:8000/user_health_data/user_has_health_data'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return response.body == 'true';
  } else {
    throw Exception('Failed to check user health data');
  }
}

Future<Map<String, dynamic>> fetchUserHealthDataDataForPrediction(String? token) async {
  try {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:8000/user_health_data/get_user_health_data_for_user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData as Map<String, dynamic>;
    } else {
      throw Exception('Failed to check user health data: ${response.body}');
    } 
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

Future<double> getCVDPredictionPercentage(String? token) async {
  final response = await http.get(
    Uri.parse('https://10.0.2.2:8000/user_health_data/predict_cvd_probability'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = json.decode(response.body);
    return (body['prediction'] as num).toDouble();
  } else {
    throw Exception("Failed to fetch CVD prediction: ${response.body}");
  }
}