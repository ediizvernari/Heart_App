import 'package:dio/dio.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/network/api_client.dart';

class AuthApi {
  static final _noAuthOptions = Options(extra: {'noAuth': true});

  static Future<AuthResponse> loginAccount(LoginRequest dto) async {
    try {
      final Response<dynamic> response = await ApiClient.post(APIConstants.loginUrl, dto.toJson(), options: Options(extra: {'noAuth': true}));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw ApiException(
        response.statusCode ?? 0,
        response.statusMessage ?? 'Unknown error during login.',
      );
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<AuthResponse> signupUser(UserSignupRequest dto) async {
    try {
      final Response<dynamic> response = await ApiClient.post(APIConstants.userSignupUrl, dto.toJson(), options: _noAuthOptions);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw ApiException(
        response.statusCode ?? 0,
        response.statusMessage ?? 'Unknown error during user signup.',
      );
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<AuthResponse> signupMedic(MedicSignupRequest dto) async {
    try {
      final Response<dynamic> response = await ApiClient.post(APIConstants.medicSignupUrl, dto.toJson(), options: Options(extra: {'noAuth': true}));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(
        response.statusCode ?? 0,
        response.statusMessage ?? 'Unknown error during medic signup.',
      );
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<bool> isEmailAvailableForSignup(String email, bool isMedic) async {
    final String endpoint = isMedic
      ? '${APIConstants.checkMedicEmailUrl}?email=$email'
      : '${APIConstants.checkUserEmailUrl}?email=$email';

    try {
      final response = await ApiClient.get(endpoint, options: _noAuthOptions);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data['available'] == true;
      } else if (response.statusCode == 400) {
        return false;
      }

      throw ApiException(
        response.statusCode ?? 0,
        response.statusMessage ?? 'Unknown error checking email availability.',
      );
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      if (statusCode == 400) return false;
      throw ApiException(statusCode, errorMessage!);
    }
  }
}
