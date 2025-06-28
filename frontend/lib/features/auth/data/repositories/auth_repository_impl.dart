import 'package:frontend/features/auth/data/api/auth_api.dart';
import 'package:frontend/features/auth/auth_exception/auth_exception.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/core/network/api_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResponse> login(LoginRequest dto) async {
    try {
      return await AuthApi.login(dto);
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 400 || e.statusCode == 401) {
          throw AuthException.invalidCredentials();
        }
        if (e.statusCode >= 500) {
          throw AuthException.serverError(e.message);
        }
      }
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<AuthResponse> signupUser(UserSignupRequest dto) async {
    try {
      return await AuthApi.signupUser(dto);
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        throw AuthException.emailAlreadyInUse();
      }
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<AuthResponse> signupMedic(MedicSignupRequest dto) async {
    try {
      return await AuthApi.signupMedic(dto);
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        throw AuthException.emailAlreadyInUse();
      }
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<bool> isEmailAvailableForSignup(String email, bool isMedic) {
    return AuthApi.isEmailAvailableForSignup(email, isMedic);
  }
}