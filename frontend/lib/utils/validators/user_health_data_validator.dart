class UserHealthDataValidator {
  static bool isFieldEmpty(String value) {
    return value.isEmpty;
  }

  static bool isValidInteger(String value) {
    final intValue = int.tryParse(value);
    return intValue != null && intValue >= 0;
  }

  static bool isDropDownSelected(int? value) {
    return value == null;
  }

  static bool validateUserHealthData({
    required String birthDate,
    required String height,
    required String weight,
    required int? cholesterolLevel,
    required String diastolicBP,
    required String systolicBP,
  }) {
    if (isFieldEmpty(birthDate) ||
        isFieldEmpty(height) ||
        isFieldEmpty(weight) ||
        isFieldEmpty(diastolicBP) ||
        isFieldEmpty(systolicBP) ||
        cholesterolLevel == null) {
      return false;
    }

    if (!isValidInteger(height) ||
        !isValidInteger(weight) ||
        !isValidInteger(systolicBP) ||
        !isValidInteger(diastolicBP)) {
      return false;
    }

    return true;
  }
}
