import 'package:intl/intl.dart';

class UserHealthDataValidator {
  String? errorMessage;

  static bool _isFieldEmpty(String value) {
    return value.isEmpty;
  }

  static bool _isValidInteger(String value) {
    final intValue = int.tryParse(value);
    return intValue != null && intValue >= 0;
  }

  static String? validateUserHealthData({
    required String birthDate,
    required String height,
    required String weight,
    required String systolicBP,
    required String diastolicBP,
    required int? cholesterolLevel,
  }) {
    final birthDateError = validateBirthDate(birthDate);
    if (birthDateError != null) return birthDateError;

    final heightError = validateHeight(height);
    if (heightError != null) return heightError;

    final weightError = validateWeight(weight);
    if (weightError != null) return weightError;

    final sysBpError = validateSystolicBP(systolicBP);
    if (sysBpError != null) return sysBpError;

    final diaBpError = validateDiastolicBP(diastolicBP);
    if (diaBpError != null) return diaBpError;

    final cholesterolError = validateCholesterolLevel(cholesterolLevel);
    if (cholesterolError != null) return cholesterolError;

    return null;
  }

  static String? validateBirthDateField(String birthDate) {
    if (_isFieldEmpty(birthDate)) {
      return 'Please enter your date of birth';
    }
    try {
      DateFormat('dd/MM/yyyy').parse(birthDate);
    } catch (_) {
      return 'Invalid date format. Use dd/MM/yyyy';
    }
    return null;
  }

  static String? validateBirthDate(String birthDate) {
    if (_isFieldEmpty(birthDate)) {
      return 'Please enter your date of birth';
    }
    try {
      DateFormat('dd/MM/yyyy').parse(birthDate);
    } catch (_) {
      return 'Invalid date format. Use dd/MM/yyyy';
    }
    return null;
  }

  static String? validateHeight(String height) {
    if (_isFieldEmpty(height)) {
      return 'Please enter your height';
    }
    if (!_isValidInteger(height)) {
      return 'Height must be a valid number';
    }
    final intHeight = int.parse(height);
    if (intHeight < 80) {
      return 'Height must be at least 80 cm';
    }
    return null;
  }

  static String? validateWeight(String weight) {
    if (_isFieldEmpty(weight)) {
      return 'Please enter your weight';
    }
    if (!_isValidInteger(weight)) {
      return 'Weight must be a valid number';
    }
    final intWeight = int.parse(weight);
    if (intWeight < 40) {
      return 'Weight must be at least 40 kg';
    }
    return null;
  }

  static String? validateSystolicBP(String systolicBP) {
    if (_isFieldEmpty(systolicBP)) {
      return 'Please enter your systolic blood pressure';
    }
    if (!_isValidInteger(systolicBP)) {
      return 'Systolic BP must be a valid number';
    }
    final intSystolicBP = int.parse(systolicBP);
    if (intSystolicBP < 70 || intSystolicBP > 200) {
      return 'Systolic BP must be between 70 and 250 mmHg';
    }
    return null;
  }

  static String? validateDiastolicBP(String diastolicBP) {
    if (_isFieldEmpty(diastolicBP)) {
      return 'Please enter your diastolic blood pressure';
    }
    if (!_isValidInteger(diastolicBP)) {
      return 'Diastolic BP must be a valid number';
    }
    final intDiastolicBP = int.parse(diastolicBP);
    if (intDiastolicBP < 40 || intDiastolicBP > 150) {
      return 'Diastolic BP must be between 40 and 150 mmHg';
    }
    return null;
  }

  static String? validateCholesterolLevel(int? value) {
    if (value == null) return 'Cholesterol level is required';
    return null;
  }
}
