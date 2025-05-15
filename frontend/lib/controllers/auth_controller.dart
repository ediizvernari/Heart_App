import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/validators/auth_form_validator.dart';
import '../utils/validators/auth_validator.dart';
import '../services/auth_service.dart';
import '../views/screens/user_main_page.dart';
import '../views/screens/medic_main_page.dart';
import '../utils/ui/dialog_utils.dart';


//TODO: Split this file into multiple files for better organization (only if needed)
class AuthController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> handleLogInButton({
  required BuildContext context,
  required String email,
  required String password,
  }) async {
  final String? loginError = await AuthValidator.validateAllFieldsForLogin(email: email, password: password);

  if (loginError != null) {
    DialogUtils.showAlertDialog(context, "Login Error", loginError);
    return;
  }

  try {
    final String? token = await AuthService.loginUser(email, password);

      if (token == null) {
        DialogUtils.showAlertDialog(context, "Login Error", "Invalid credentials.");
        return;
      }

      await storage.write(key: 'auth_token', value: token);
      final String? role = getAccountRole(token);

      if (role == "user") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClientMainPage()),
        );
      } else if (role == "medic") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MedicMainPage()),
        );
      } else {
        DialogUtils.showAlertDialog(context, "Login Error", "Invalid user role.");
      }
    } catch (e) {
      DialogUtils.showAlertDialog(context, "Login Failed", "Incorrect email or password.");
    }
  }


  String? getAccountRole(String? token) {
    if (token == null || JwtDecoder.isExpired(token)) return null;

    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['role'];
  }

  Future<void> handleUserSignUpButton({
    required BuildContext context,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    final String? signUpError = await AuthValidator.validateAllFieldsForSignUp(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      isMedic: false,
    );

    if (signUpError != null) {
      DialogUtils.showAlertDialog(context, "Error While Signing Up", signUpError);
      return;
    }

    final Map<String, String> dataForUserSignUp = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };

    final String? token = await AuthService.registerAccount(
      dataForSignup: dataForUserSignUp,
      isMedic: false,
    );

    if (token == null) {
      DialogUtils.showAlertDialog(context, "Error While Signing Up", "The account could not be created");
      return;
    }

    await storage.write(key: 'auth_token', value: token);
    final String? role = getAccountRole(token);

    if (role == "user") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientMainPage()),
      );
    } else {
      DialogUtils.showAlertDialog(context, "Error While Signing Up", "Invalid user role");  
    }
  }  

  Future<String?> validateMedicStepOneFields({
  required String email,
  required String password,
  required String confirmPassword,
  required String firstName,
  required String lastName,
  }) async {
    return await AuthValidator.validateAllFieldsForSignUp(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      isMedic: true,
    );
  }

  Future<String?> validateMedicStepTwoFields({
  required String streetAddress,
  required String city,
  required String country,
  }) async {
    return await AuthFormValidator.validateMedicAddressFields(
      streetAddress: streetAddress,
      city: city,
      country: country,
    );
  }

  Future<void> handleMedicSignUpButton({
  required BuildContext context,
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String streetAddress,
  required String city,
  required String country,
  }) async {
    final Map<String, String> dataForMedicSignUp = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'street_address': streetAddress,
      'city': city,
      'country': country,
    };

    final String? token = await AuthService.registerAccount(
      dataForSignup: dataForMedicSignUp,
      isMedic: true,
    );

    if (token == null) {
      DialogUtils.showAlertDialog(context, "Sign-Up Failed", "Unable to create the medic account.");
      return;
    }

    await storage.write(key: 'auth_token', value: token);
    final String? role = getAccountRole(token);

    if (role == "medic") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MedicMainPage()),
      );
    } else {
      DialogUtils.showAlertDialog(context, "Error", "Invalid medic role returned.");
    }
  }

}

