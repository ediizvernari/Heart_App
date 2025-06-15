class AuthFormValidator {
  static String? validateEmailFormat(String email) {
    if (email.isEmpty) return 'Email cannot be empty';
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < 8) return 'Password must be at least 8 characters long';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Password must contain at least one number';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Password must contain at least one uppercase letter';
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Confirm password cannot be empty';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  static String? validateFirstName(String firstName) {
    if (firstName.isEmpty) return 'First name cannot be empty';
    return null;
  }

  static String? validateLastName(String lastName) {
    if (lastName.isEmpty) return 'Last name cannot be empty';
    return null;
  }

  static String? validateMedicAddressFields({
    required String streetAddress,
    required String city,
    required String country,
  }) {
    if (streetAddress.isEmpty) return 'Street address field cannot be empty';
    if (city.isEmpty) return 'City field cannot be empty';
    if (country.isEmpty) return 'Country field cannot be empty';
    return null;
  }
}
