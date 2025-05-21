import 'dart:convert';

import 'package:frontend/core/api_constants.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/services/api_exception.dart';

import '../../../../services/api_client.dart';


class AuthApi {

  static Future<AuthResponse> loginAccount(LoginRequest dto) async {
    final response = await APIClient.post(APIConstants.loginUrl, dto.toJson());

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return AuthResponse.fromJson(json);
    }

    throw ApiException(response.statusCode, response.body);
  }

  static Future<AuthResponse> signupUser(UserSignupRequest dto) async {
    final response = await APIClient.post(APIConstants.userSignupUrl, dto.toJson());

    if(response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }
     throw ApiException(response.statusCode, response.body);
  }

  static Future<AuthResponse> signupMedic(MedicSignupRequest dto) async {
    final response = await APIClient.post(APIConstants.medicSignupUrl, dto.toJson());
    
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    throw ApiException(response.statusCode, response.body);
  }

  static Future<bool> isEmailAvailableForSignup(String email, bool isMedic) async {
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
      throw ApiException(response.statusCode, response.body);
    }
  }
}
