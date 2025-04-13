import 'network_utils.dart';

Future<String?> validateEmail(String email, {required bool isMedic}) async {
  final String? emailError = validateEmailFormat(email);
  if (emailError != null) return emailError;

  try {
    final available = await isEmailAvailableForSignup(email, isMedic: isMedic);
    if (!available) return 'Email already registered1';
  } catch (e) {
    return 'Error checking email: ${e.toString()}';
  }

  return null;
}

String? validateEmailFormat(String email) {
  if (email.isEmpty) return 'Email cannot be empty';
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(email)) return 'Invalid email format';
  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) return 'Password cannot be empty';
  if (password.length < 8) return 'Password must be at least 8 characters long';
  if (!password.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number';
  if (!password.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter';
  return null;
}

String? validateConfirmPassword(String password, String confirmPassword) {
  if (confirmPassword.isEmpty) return 'Confirm password cannot be empty';
  if (password != confirmPassword) return 'Passwords do not match';
  return null;
}

String? validateFirstName(String firstName) {
  if (firstName.isEmpty) return 'First name cannot be empty';
  return null;
}

String? validateLastName(String lastName) {
  if (lastName.isEmpty) return 'Last name cannot be empty';
  return null;
}

Future<String?> validateAllFieldsForLogin({
  required String email,
  required String password,
}) async {
  final String? emailError = validateEmailFormat(email);
  if (emailError != null) return emailError;

  final String? passwordError = validatePassword(password);
  if (passwordError != null) return passwordError;

  return null;
}

Future<String?> validateAllFieldsForSignUp({
  required String email,
  required String password,
  required String confirmPassword,
  required String firstName,
  required String lastName,
  required bool isMedic,
}) async {
  final emailError = await validateEmail(email, isMedic: isMedic);
  if (emailError != null) return emailError;

  final passwordError = validatePassword(password);
  if (passwordError != null) return passwordError;

  final confirmError = validateConfirmPassword(password, confirmPassword);
  if (confirmError != null) return confirmError;

  final firstNameError = validateFirstName(firstName);
  if (firstNameError != null) return firstNameError;

  final lastNameError = validateLastName(lastName);
  if (lastNameError != null) return lastNameError;

  return null;
}


Future<String?> validateMedicAddressFields({
  required String streetAddress,
  required String city,
  required String postalCode,
  required String country,
}) async {
  if (streetAddress.isEmpty) return 'Street address field cannot be empty';
  if (city.isEmpty) return 'City field cannot be empty';
  if (postalCode.isEmpty) return 'Postal code field cannot be empty';
  if (country.isEmpty) return 'Country field cannot be empty';
  return null;
}