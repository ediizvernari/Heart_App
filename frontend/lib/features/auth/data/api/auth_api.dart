import 'package:dio/dio.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/network/api_client.dart';

class AuthApi {
  static final _noAuthOptions = Options(extra: {'noAuth': true});

  static Future<AuthResponse> login(LoginRequest dto) async {
    final response = await ApiClient.post(
      APIConstants.loginUrl,
      dto.toJson(),
      options: _noAuthOptions,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    }
    throw ApiException(
      response.statusCode ?? 0,
      response.statusMessage ?? 'Unknown error during login.',
    );
  }

  static Future<AuthResponse> signupUser(UserSignupRequest dto) async {
    final response = await ApiClient.post(
      APIConstants.userSignupUrl,
      dto.toJson(),
      options: _noAuthOptions,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    }
    throw ApiException(
      response.statusCode ?? 0,
      response.statusMessage ?? 'Unknown error during user signup.',
    );
  }

  static Future<AuthResponse> signupMedic(MedicSignupRequest dto) async {
    final response = await ApiClient.post(
      APIConstants.medicSignupUrl,
      dto.toJson(),
      options: _noAuthOptions,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    }
    throw ApiException(
      response.statusCode ?? 0,
      response.statusMessage ?? 'Unknown error during medic signup.',
    );
  }

  static Future<bool> isEmailAvailableForSignup(String email, bool isMedic) async {
    final endpoint = isMedic
        ? APIConstants.checkMedicEmailUrl
        : APIConstants.checkUserEmailUrl;
    final response = await ApiClient.get(
      '$endpoint?email=$email',
      options: _noAuthOptions,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data['available'] == true;
    }
    if (response.statusCode == 400) return false;
    throw ApiException(
      response.statusCode ?? 0,
      response.statusMessage ?? 'Unknown error checking email availability.',
    );
  }
}
