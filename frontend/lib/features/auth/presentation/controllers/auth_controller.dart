import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_exception.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:frontend/features/medics/presentation/pages/medic_main_page.dart';
import 'package:frontend/features/users/presentation/pages/user_main_page.dart';
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
  AuthResponse? _authResponse;
  String? _error;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  AuthResponse? get authToken => _authResponse;
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
    final String? loginErrorMessage = await AuthValidator.validateAllFieldsForLogin(email: _email, password: _password);
    if(loginErrorMessage != null) {
      _error = loginErrorMessage;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _authResponse = await _repository.login(LoginRequest(email: _email, password: _password));

      await AuthStore.saveToken(_authResponse!.accessToken);
      Navigator.of(context).pushReplacementNamed(_homeRouteForToken(_authResponse!.accessToken));
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Login failed. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signupUser ({required BuildContext context, required UserSignupRequest userSignupDto, required String confirmPassword}) async {
    final String? signUpErrorMessage = await AuthValidator.validateAllFieldsForSignUp(
    email: userSignupDto.email,
    password: userSignupDto.password,
    confirmPassword: confirmPassword,
    firstName: userSignupDto.firstName,
    lastName: userSignupDto.lastName,
    isMedic: false,
    );

    if (signUpErrorMessage != null) {
      _error = signUpErrorMessage;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _authResponse = await _repository.signupUser(userSignupDto);
      await AuthStore.saveToken(_authResponse!.accessToken);
      Navigator.of(context).pushReplacementNamed(_homeRouteForToken(_authResponse!.accessToken));
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'User signup failed.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signupMedic({required BuildContext context, required MedicSignupRequest medicSignupDto, required String confirmPassword}) async {
    final String? signUpErrorMessage = await AuthValidator.validateAllFieldsForSignUp(
    email: medicSignupDto.email,
    password: medicSignupDto.password,
    confirmPassword: confirmPassword,
    firstName: medicSignupDto.firstName,
    lastName: medicSignupDto.lastName,
    isMedic: true,
    );

    if (signUpErrorMessage != null) {
      _error = signUpErrorMessage;
      notifyListeners();
      return;
    }

    final String? addressErrorMessage = AuthFormValidator.validateMedicAddressFields(
      streetAddress: medicSignupDto.streetAddress,
      city: medicSignupDto.city,
      country: medicSignupDto.country,
    );
    if (addressErrorMessage != null) {
      _error = addressErrorMessage;
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _authResponse = await _repository.signupMedic(medicSignupDto);
      await AuthStore.saveToken(_authResponse!.accessToken);
      Navigator.of(context).pushReplacementNamed(_homeRouteForToken(_authResponse!.accessToken));
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Medic signup failed.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;

    await AuthStore.clearToken();
    _authResponse = null;
    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<bool> checkEmailAvailability({ required bool isMedic }) {
    return _repository.isEmailAvailableForSignup(_email, isMedic);
  }


  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  String _homeRouteForToken(String token) {
    final payload = JwtDecoder.decode(token);
    final role = payload['role'] as String? ?? 'user';
    return role == 'medic' ? '/medic_home' : '/user_home';
  }

  Future<void> ensureSession(BuildContext context) async {
    debugPrint('AuthStore.ensureSession: starting session check');

    final token = await AuthStore.getToken();
    debugPrint('AuthStore.ensureSession: raw token = $token');

    if (token == null) {
      debugPrint('AuthStore.ensureSession: no token found, redirecting to HomeScreen');
      await AuthStore.clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
      return;
    }

    final expired = JwtDecoder.isExpired(token);
    debugPrint('AuthStore.ensureSession: token expired? $expired');

    if (expired) {
      debugPrint('AuthStore.ensureSession: token expired, clearing and redirecting to HomeScreen');
      await AuthStore.clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
      return;
    }

    final payload = JwtDecoder.decode(token);
    final role = payload['role'] as String?;
    debugPrint('AuthStore.ensureSession: decoded payload = $payload');
    debugPrint('AuthStore.ensureSession: user role = $role');

    Widget next;
    if (role == 'medic') {
      debugPrint('AuthStore.ensureSession: navigating to MedicMainPage');
      next = const MedicMainPage();
    } else {
      debugPrint('AuthStore.ensureSession: navigating to UserMainPage');
      next = const UserMainPage();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (_) => false,
    );
    debugPrint('AuthStore.ensureSession: navigation complete');
  }
}