import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/authentication_validator.dart';
import '../utils/network_utils.dart';
import '../screens/client_main_page.dart';
import '../screens/medic_main_page.dart';

class AuthController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> handleLogInButton({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  final String? loginError = await validateAllFieldsForLogin(email: email, password: password);

  if (loginError != null) {
    _showDialog(context, "Login Error", loginError);
    return;
  }

  try {
    final String? token = await loginUser(email, password);

      if (token == null) {
        _showDialog(context, "Login Error", "Invalid credentials.");
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
        _showDialog(context, "Login Error", "Invalid user role.");
      }
    } catch (e) {
      _showDialog(context, "Login Failed", "Incorrect email or password.");
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
    final String? signUpError = await validateAllFieldsForSignUp(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      isMedic: false,
    );

    if (signUpError != null) {
      _showDialog(context, "Error While Signing Up", signUpError);
      return;
    }

    final Map<String, String> dataForUserSignUp = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };

    final String? token = await registerAccount(
      dataForSignup: dataForUserSignUp,
      isMedic: false,
    );

    if (token == null) {
      _showDialog(context, "Error While Signing Up", "The account could not be created");
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
      _showDialog(context, "Error While Signing Up", "Invalid user role");  
    }
  }

  //TODO: Implement the UI utils for showing dialogs alerts and so on
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      )
    );
  }

  Future<String?> validateMedicStepOneFields({
  required String email,
  required String password,
  required String confirmPassword,
  required String firstName,
  required String lastName,
  }) async {
    return await validateAllFieldsForSignUp(
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
  required String postalCode,
  required String country,
  }) async {
    return await validateMedicAddressFields(
      streetAddress: streetAddress,
      city: city,
      postalCode: postalCode,
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
  required String postalCode,
  required String country,
  }) async {
    final Map<String, String> dataForMedicSignUp = {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'street_address': streetAddress,
      'city': city,
      'postal_code': postalCode,
      'country': country,
    };

    final String? token = await registerAccount(
      dataForSignup: dataForMedicSignUp,
      isMedic: true,
    );

    if (token == null) {
      _showDialog(context, "Sign-Up Failed", "Unable to create the medic account.");
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
      _showDialog(context, "Error", "Invalid medic role returned.");
    }
  }

}

