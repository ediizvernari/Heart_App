import 'package:http/http.dart' as http;

Future<String?> validateEmail(String email) async {
  String? emailError = await validateEmailFormat(email);
  if (emailError != null) {
    return emailError;
  }
  
final response = await http.get(Uri.parse('https://10.0.2.2:8000/users/check_email?email=$email'));
  if (response.statusCode == 400) {
    return 'Email already registered';
  } else if (response.statusCode != 200) {
    return 'Status Code: ${response.statusCode}, Message: Error checking email';
  }

  return null;
}

Future<String?> validateEmailFormat(String email) async {
  if (email.isEmpty) {
    return 'Email cannot be empty';
  }
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(email)) {
    return 'Invalid email format';
  }

  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) {
    return 'Password cannot be empty';
  } else if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  } else if(!password.contains(RegExp(r'[0-9]'))){
    return 'Password must contain at least one number';
  } else if(!password.contains(RegExp(r'[A-Z]'))){
    return 'Password must contain at least one uppercase letter';
  }
  return null;
}

String? validateConfirmPassword(String password, String confirmPassword) {
  if (confirmPassword.isEmpty) {
    return 'Confirm password cannot be empty';
  } else if (password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null;
}

String? validateFirstName(String firstName) {
  if (firstName.isEmpty) {
    return 'First name cannot be empty';
  }
  return null;
}

String? validateLastName(String lastName) {
  if (lastName.isEmpty) {
    return 'Last name cannot be empty';
  }
  return null;
}

Future<String?> validateAllFieldsForSignUp(String email, String password, String confirmPassword, String firstName, String lastName) async {
  final String? emailError = await validateEmail(email);
  if (emailError != null) {
    return emailError;
  }
  final String? passwordError = validatePassword(password);
  if (passwordError != null) {
    return passwordError;
  }
  final String? confirmPasswordError = validateConfirmPassword(password, confirmPassword);
  if (confirmPasswordError != null) {
    return confirmPasswordError;
  }
  final String? firstNameError = validateFirstName(firstName);
  if (firstNameError != null) {
    return firstNameError;
  }
  final String? lastNameError = validateLastName(lastName);
  if (lastNameError != null) {
    return lastNameError;
  }
  return null;
}

Future<String?> validateAllFieldsForLogin(String email, String password) async {
  final String? emailError = await validateEmailFormat(email);
  if (emailError != null) {
    return emailError;
  }
  final String? passwordError = validatePassword(password);
  if (passwordError != null) {
    return passwordError;
  }
  return null;
}