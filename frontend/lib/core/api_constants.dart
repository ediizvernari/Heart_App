class APIConstants {
  static const baseUrl = 'https://10.0.2.2:8000';

  static const userSignupUrl = '$baseUrl/auth/user_signup';
  static const medicSignupUrl = '$baseUrl/auth/medic_signup';
  static const loginUrl = '$baseUrl/auth/login';
  static const checkUserEmailUrl = '$baseUrl/auth/check_email_for_user';
  static const checkMedicEmailUrl = '$baseUrl/auth/check_email_for_medic';
  static const checkCvdPredictionUrl = '$baseUrl/cvd_prediction/predict_cvd_probability';
  static const fetchUserHealthDataForUserUrl = '$baseUrl/user_health_data/get_user_health_data_for_user';
  static const checkUserHasHealthDataUrl = '$baseUrl/user_health_data/user_has_health_data';
}