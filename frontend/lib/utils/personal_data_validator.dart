class FormValidators {
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

  static bool validatePersonalData({
    required String birthDate,
    required String height,
    required String weight,
    required String cigarettesPerDay,
    required String cholesterol,
    required String glucose,
    required int? selectedSex,
    required int? selectedEducationLevel,
    required int? currentSmoker,
    required int? bpmMed,
    required int? prevalentStroke,
    required int? prevalentHyp,
    required int? diabetes,
  }) {
    if (isFieldEmpty(birthDate) ||
        isFieldEmpty(height) ||
        isFieldEmpty(weight) ||
        isFieldEmpty(cigarettesPerDay) ||
        isFieldEmpty(cholesterol) ||
        isFieldEmpty(glucose) ||
        isDropDownSelected(selectedSex) ||
        isDropDownSelected(selectedEducationLevel) ||
        isDropDownSelected(currentSmoker) ||
        isDropDownSelected(bpmMed) ||
        isDropDownSelected(prevalentStroke) ||
        isDropDownSelected(prevalentHyp) ||
        isDropDownSelected(diabetes)) {
      return false;
    }

    if (!isValidInteger(height) ||
        !isValidInteger(weight) ||
        !isValidInteger(cigarettesPerDay) ||
        !isValidInteger(cholesterol) ||
        !isValidInteger(glucose)) {
      return false;
    }

    return true;
  }
}
