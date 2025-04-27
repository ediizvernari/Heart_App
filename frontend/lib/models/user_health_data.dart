class UserHealthData {
  final String dateOfBirth;
  final String heightCm;
  final String weightKg;
  final String cholesterolLevel;
  final String systolicBloodPressure;
  final String diastolicBloodPressure;

  UserHealthData({
    required this.dateOfBirth,
    required this.heightCm,
    required this.weightKg,
    required this.cholesterolLevel,
    required this.systolicBloodPressure,
    required this.diastolicBloodPressure,
  });

  factory UserHealthData.fromJson(Map<String, dynamic> json) {
    return UserHealthData(
      dateOfBirth: json['date_of_birth'] as String,
      heightCm: json['height_cm'] as String,
      weightKg: json['weight_kg'] as String,
      cholesterolLevel: json['cholesterol_level'] as String,
      systolicBloodPressure: json['systolic_blood_pressure'] as String,
      diastolicBloodPressure: json['diastolic_blood_pressure'] as String,
    );
  }
}