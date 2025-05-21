import 'package:frontend/features/auth/data/api/auth_api.dart';
import 'package:frontend/features/auth/data/auth_exception.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/services/api_exception.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResponse> login(LoginRequest dto) async {
    try {
      return await AuthApi.loginAccount(dto);
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401) {
        throw AuthException.invalidCredentials();
      }
      if (e.statusCode >= 500) {
        throw AuthException.serverError(e.message);
      }
      throw AuthException.networkError(e.message);
    } catch (e) {
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<AuthResponse> signupUser(UserSignupRequest dto) async {
    try {
      return await AuthApi.signupUser(dto);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        throw AuthException.emailAlreadyInUse();
      }
      if (e.statusCode >= 500) {
        throw AuthException.serverError(e.message);
      }
      throw AuthException.networkError(e.message);
    } catch (e) {
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<AuthResponse> signupMedic(MedicSignupRequest dto) async {
    try {
      return await AuthApi.signupMedic(dto);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        throw AuthException.emailAlreadyInUse();
      }
      if (e.statusCode >= 500) {
        throw AuthException.serverError(e.message);
      }
      throw AuthException.networkError(e.message);
    } catch (e) {
      throw AuthException.networkError(e.toString());
    }
  }

  @override
  Future<bool> isEmailAvailableForSignup(String email, bool isMedic) async {
    try {
      return await AuthApi.isEmailAvailableForSignup(email, isMedic);
    } on ApiException catch (e) {
      throw AuthException.networkError(e.message);
    } catch (e) {
      throw AuthException.networkError(e.toString());
    }
  }
}