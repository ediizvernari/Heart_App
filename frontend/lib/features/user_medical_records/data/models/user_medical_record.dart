class UserMedicalRecord {
  final int id;
  final int userId;
  final double cvdRiskPercentage;
  final DateTime birthDate;
  final int heightCm;
  final int weightKg;
  final int cholesterolLevel;
  final int systolicBloodPressure;
  final int diastolicBloodPressure;
  final DateTime createdAt;

  UserMedicalRecord({
    required this.id,
    required this.userId,
    required this.cvdRiskPercentage,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.cholesterolLevel,
    required this.systolicBloodPressure,
    required this.diastolicBloodPressure,
    required this.createdAt,
  });

  //TODO: Change the backend types of the schemas
  factory UserMedicalRecord.fromJson(Map<String, dynamic> json) {
    final cvdRiskString = json['cvd_risk'] as String;
    final heightString = json['height'] as String;
    final weightString = json['weight'] as String;
    final cholLevelString = json['cholesterol_level'] as String;
    final apHiString = json['ap_hi'] as String;
    final apLoString = json['ap_lo'] as String;

    return UserMedicalRecord(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      cvdRiskPercentage: double.parse(cvdRiskString),
      birthDate: DateTime.parse(json['birth_date'] as String),
      heightCm: int.parse(heightString),
      weightKg: int.parse(weightString),
      cholesterolLevel: int.parse(cholLevelString),
      systolicBloodPressure: int.parse(apHiString),
      diastolicBloodPressure: int.parse(apLoString),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
