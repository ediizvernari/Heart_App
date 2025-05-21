import 'package:frontend/features/auth/data/models/auth_response.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/medic_signup_request.dart';
import 'package:frontend/features/auth/data/models/user_signup_request.dart';


abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest dto);
  Future<AuthResponse> signupUser(UserSignupRequest dto);
  Future<AuthResponse> signupMedic(MedicSignupRequest dto);
  Future<bool> isEmailAvailableForSignup(String email, bool isMedic);
}