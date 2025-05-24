import 'dart:convert';

import 'package:frontend/services/api_exception.dart';

import 'auth_form_validator.dart';
import '../../services/auth_service.dart';

class AuthValidator {
  static Future<String?> validateEmail(String email, {required bool isMedic}) async {
    final String? formatError = AuthFormValidator.validateEmailFormat(email);
    if (formatError != null) return formatError;

    try {
      //TODO: Replace the authService with the right class that calls this
      final available = await AuthService.isEmailAvailableForSignup(
        email,
        isMedic: isMedic,
      );
      if (!available) {
        return 'Email already registered';
      }
    }
    on ApiException catch (e) {
      try {
        final Map<String, dynamic> body = jsonDecode(e.responseBody);
        final detail = body['detail'] as String?;
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      } catch (_) { /* fall through */ }
      return 'Email already registered';
    }
    on Exception catch (e) {
      final msg = e.toString();
      final detailMatch = RegExp(r'\{"detail"\s*:\s*"([^"]+)').firstMatch(msg);
      if (detailMatch != null) {
        return detailMatch.group(1);
      }
      return 'Email already registered';
    }

    return null;
  }

  static Future<String?> validateAllFieldsForLogin({
    required String email,
    required String password,
  }) async {
    final String? emailError = AuthFormValidator.validateEmailFormat(email);
    if (emailError != null) return emailError;

    final String? passwordError = AuthFormValidator.validatePassword(password);
    if (passwordError != null) return passwordError;

    return null;
  }

  static Future<String?> validateAllFieldsForSignUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required bool isMedic,
  }) async {
    final emailError = await validateEmail(email, isMedic: isMedic);
    if (emailError != null) return emailError;

    final passwordError = AuthFormValidator.validatePassword(password);
    if (passwordError != null) return passwordError;

    final confirmError = AuthFormValidator.validateConfirmPassword(password, confirmPassword);
    if (confirmError != null) return confirmError;

    final firstNameError = AuthFormValidator.validateFirstName(firstName);
    if (firstNameError != null) return firstNameError;

    final lastNameError = AuthFormValidator.validateLastName(lastName);
    if (lastNameError != null) return lastNameError;

    return null;
  }
}
