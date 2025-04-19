import 'dart:convert';
import '../core/api_constants.dart';
import 'api_client.dart';

class AuthService {
  static Future<String?> loginUser(String email, String password) async {
    final response = await APIClient.post(
      APIConstants.loginUrl,
      {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['access_token'];
    } else {
      throw Exception('Failed to log in: ${response.body}');
    }
  }

  static Future<bool> isEmailAvailableForSignup(String email, {required bool isMedic}) async {
    final String url = isMedic
    ? '${APIConstants.checkMedicEmailUrl}?email=$email'
    : '${APIConstants.checkUserEmailUrl}?email=$email';

    final response = await APIClient.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['available'] == true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception ('Failed to check email availability: ${response.body}');
    }
  }
}
