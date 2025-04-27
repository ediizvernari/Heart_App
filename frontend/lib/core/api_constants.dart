// TODO: Rename some router names

class APIConstants {
  static const baseUrl = 'https://10.0.2.2:8000';

  //Auth
  static const userSignupUrl = '$baseUrl/auth/user_signup';
  static const medicSignupUrl = '$baseUrl/auth/medic_signup';
  static const loginUrl = '$baseUrl/auth/login';
  static const checkUserEmailUrl = '$baseUrl/auth/check_email_for_user';
  static const checkMedicEmailUrl = '$baseUrl/auth/check_email_for_medic';

  //Prediction
  static const checkCvdPredictionUrl = '$baseUrl/cvd_prediction/predict_cvd_probability';

  //User
  static const userHasMedicUrl = '$baseUrl/users/has_medic';
  static const assignmentStatusUrl = '$baseUrl/users/assignment_status';
  static const assignMedicUrl = '$baseUrl/users/assign_medic';
  static const changeSharingPreferenceStatusUrl = '$baseUrl/users/share_data';
  static const getAssignedMedicUrl = '$baseUrl/users/assigned_medic';
  static const unassignMedicUrl = '$baseUrl/users/unassign_medic';
  
  //User Health Data
  static const fetchUserHealthDataForUserUrl = '$baseUrl/user_health_data/get_user_health_data_for_user';
  static const checkUserHasHealthDataUrl = '$baseUrl/user_health_data/user_has_health_data';
  
  //Location
  static const autocompleteCitiesUrl = '$baseUrl/location/autocomplete_cities';
  static const getCountriesUrl = '$baseUrl/location/countries';
  
  //Medic
  static const getFilteredMedicsUrl = '$baseUrl/medics/filtered_medics';
  static const getAssignedPatientsUrl = '$baseUrl/medics/patients';
  static String getPatientHealthDataUrl(int userID) {
    return '$baseUrl/medics/patients/$userID/data';
  }
  static String fetchAllPatientMedicalRecordsUrl(int userID) {
    return '$baseUrl/medics/patients/$userID/medical_records';
  }
  static String fetchLatestPatientMedicalRecordUrl(int userID) {
    return '$baseUrl/medics/patients/$userID/medical_records/latest';
  }

  //User Medical Record
  static const getAllMedicalRecordsForUserUrl = '$baseUrl/user_medical_records/all';
  static const getLatestMedicalRecordForUserUrl = '$baseUrl/user_medical_records/latest';
}