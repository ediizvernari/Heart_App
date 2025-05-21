import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_exception.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/utils/auth_store.dart';
import 'package:frontend/utils/validators/auth_form_validator.dart';
import 'package:frontend/utils/validators/auth_validator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/auth_response.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);
  final AuthRepository _repository;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  AuthResponse? _user;
  String? _error;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  AuthResponse? get user => _user;
  String? get error => _error;

  set email(String value) {
    _email = value;
    notifyListeners();
  }
  set password(String value) {
    _password = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> login({ required BuildContext context }) async {
    final String? validationMsg = await AuthValidator.validateAllFieldsForLogin(
      email: _email, password: _password,
    );
    if (validationMsg != null) {
      _error = validationMsg;
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _user = await _repository.login(
        LoginRequest(email: _email, password: _password),
      );
    }
    on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return;
    } catch (e, st) {
      debugPrint('login() repo error: $e\n$st');
      _error = 'An unexpected error occurred during login.';
      _setLoading(false);
      return;
    }

    try {
      await AuthStore.saveToken(_user!.accessToken);
    } catch (e, st) {
      debugPrint('login() token save error: $e\n$st');
      _error = 'Could not save authentication token.';
      _setLoading(false);
      return;
    }

    try {
      _navigateByRole(context, _user!.accessToken);
    } catch (e, st) {
      debugPrint('login() navigation error: $e\n$st');
      _error = 'Navigation failed after login.';
      _setLoading(false);
      return;
    }

    _setLoading(false);
  }

  Future<void> signup({
  required BuildContext context,
  required bool isMedic,
  String? email,
  String? firstName,
  String? lastName,
  String? confirmPassword,
  String? streetAddress,
  String? city,
  String? country,
}) async {
    final String? signupMsg = await AuthValidator.validateAllFieldsForSignUp(
      email: _email,
      password: _password,
      confirmPassword: confirmPassword ?? '',
      firstName: firstName  ?? '',
      lastName: lastName   ?? '',
      isMedic: isMedic,
    );
    if (signupMsg != null) {
      _error = signupMsg;
      notifyListeners();
      return;
    }

    if (isMedic) {
      final String? addrMsg = AuthFormValidator.validateMedicAddressFields(
        streetAddress: streetAddress ?? '',
        city: city ?? '',
        country: country ?? '',
      );
      if (addrMsg != null) {
        _error = addrMsg;
        notifyListeners();
        return;
      }
    }

    _setLoading(true);
    try {
      if (isMedic) {
        final MedicSignupRequest medicDto = MedicSignupRequest(
          email: _email,
          password: _password,
          firstName: firstName!,
          lastName: lastName!,
          streetAddress: streetAddress!,
          city: city!,
          country: country!,
        );
        _user = await _repository.signupMedic(medicDto);

      } else {
        final UserSignupRequest userDto = UserSignupRequest(
          email: _email,
          password: _password,
          firstName: firstName!,
          lastName: lastName!,
        );
        _user = await _repository.signupUser(userDto);
      }

      await AuthStore.saveToken(_user!.accessToken);
      _navigateByRole(context, _user!.accessToken);

    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = isMedic ? 'Medic signup failed.' : 'Signup failed.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailAvailability({ required bool isMedic }) {
    return _repository.isEmailAvailableForSignup(_email, isMedic);
  }


  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _navigateByRole(BuildContext context, String token) {
    final String? role = JwtDecoder.decode(token)['role'] as String?;
    if (role == 'user') {
      Navigator.pushReplacementNamed(context, '/user_home');
    } else if (role == 'medic') {
      Navigator.pushReplacementNamed(context, '/medic_home');
    } else {
      _error = 'Unknown role: $role';
      notifyListeners();
    }
  }
}