import 'user_health_data.dart';

class UserMedicalRecord extends UserHealthData {
  final int id;
  final int userId;
  final String cvdRiskPercentage;
  final DateTime createdAt;

  UserMedicalRecord({
    required this.id,
    required this.userId,
    required this.cvdRiskPercentage,
    required this.createdAt,
    required super.dateOfBirth,
    required super.heightCm,
    required super.weightKg,
    required super.cholesterolLevel,
    required super.systolicBloodPressure,
    required super.diastolicBloodPressure,
  });

  factory UserMedicalRecord.fromJson(Map<String, dynamic> json) {
    return UserMedicalRecord(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      cvdRiskPercentage: json['cvd_risk_percentage'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dateOfBirth: json['birth_date'] as String,
      heightCm: json['height'] as String,
      weightKg: json['weight'] as String,
      cholesterolLevel: json['cholesterol_level'] as String,
      systolicBloodPressure: json['ap_hi'] as String,
      diastolicBloodPressure: json['ap_lo'] as String,
    );
  }
}
