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
    Uri.parse('https://10.0.2.2:8000/cvd_prediction/predict_cvd_probability'),
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

Future<String?> loginUser(String email, String password) async {
  const String url = 'https://10.0.2.2:8000/auth/login';

  final response = await http.post(
    Uri.parse(url),
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String> {
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    return responseBody['access_token'];
  } else {
    throw Exception('Failed to log in: ${response.body}');
  }
}

Future<String?> registerAccount ({
  required Map<String, String> dataForSignup,
  required bool isMedic,
}) async {
  final String url = isMedic
  ? 'https://10.0.2.2:8000/auth/medic_signup'
  : 'https://10.0.2.2:8000/auth/user_signup';

  final response = await http.post(
    Uri.parse(url),
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(dataForSignup),
  );

  final body = json.decode(response.body);
  if(response.statusCode == 200) {
    return body['access_token'];
  } else {
    return body['detail'];
  }
}

Future<bool> isEmailAvailableForSignup(String email, {required bool isMedic}) async {
  final String baseUrl = isMedic
      ? 'https://10.0.2.2:8000/auth/check_email_for_medic'
      : 'https://10.0.2.2:8000/auth/check_email_for_user';

  final response = await http.get(Uri.parse('$baseUrl?email=$email'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['available'] == true;
  } else if (response.statusCode == 400) {
    return false;
  } else {
    throw Exception('Error checking email availability: ${response.body}');
  }
}