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

  //Medical Services
  static const getMedicalServicesTypesUrl = '$baseUrl/medical_service/medical_service_types';
  static const getMedicalServicesUrl = '$baseUrl/medical_service/medical_services';
  static const createMedicalServiceUrl = '$baseUrl/medical_service/create_medical_service';
  static String updateMedicalServiceUrl(int id) {
    return '$baseUrl/medical_service/$id';
  }
  static String deleteMedicalServiceUrl(int id) {
    return '$baseUrl/medical_service/$id';
  }
  static String getMedicalServicesByMedicIdUrl(int medicID) =>
    '$baseUrl/medical_service/by_medic/$medicID';
 

  //Appointments
  static const getAllUserAppointmentsUrl = '$baseUrl/appointments/my_appointments';
  static const getAllMedicAppointmentsUrl = '$baseUrl/appointments/medic_appointments';
  static const bookAppointmentUrl = '$baseUrl/appointments/';
  //TODO: Maybe this will throw a 404
  static String changeAppointmentStatusUrl(int id, String status) =>
    '$baseUrl/appointments/$id/status?new_appointment_status=$status';

  //Appointment_Suggestions
  static String appointmentSuggestionForUser(int userId) {
    return '$baseUrl/suggestions/users/$userId';
  }
   static String changeAppointmentSuggestionStatusUrl(int appointmentSuggestionId, String appointmentSuggestionStatus) =>
      '$baseUrl/suggestions/$appointmentSuggestionId/status?new_appointment_suggestion_status=$appointmentSuggestionStatus';
  //TODO: Maybe do a router just for pending appointment suggestions that should be used by the users
  static const getAllUsersSuggestionsUrl = '$baseUrl/suggestions/mine';
  static const getAllMedicSuggestionsUrl = '$baseUrl/suggestions/for_medic';
  static String getAppointmentSuggestionById(int suggestionId) {
    return '$baseUrl/suggestions/$suggestionId';
  } 
  //TODO: Add the update suggestion status routers

  //Medic Availability
  static const String getMyAvailabilitiesUrl = '$baseUrl/medic_availability/all';
  static const String createMyAvailabilityUrl = '$baseUrl/medic_availability/create';
  static String deleteMyAvailabilityUrl(int slotId) => '$baseUrl/medic_availability/$slotId';

  //Scheduling
  static const medicFreeSlotsUrl = '$baseUrl/scheduling/medic';
  static const myAssignedMedicFreeTimeSlots = '$baseUrl/scheduling/me/free_time_slots';
}