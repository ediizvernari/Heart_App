//TODO: Change their types into the according type
import 'package:intl/intl.dart';

class UserHealthData {
  final DateTime dateOfBirth;
  final int heightCm;
  final int weightKg;
  final int cholesterolLevel;
  final int systolicBloodPressure;
  final int diastolicBloodPressure;

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
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      heightCm: json['height_cm'] as int,
      weightKg: json['weight_kg'] as int,
      cholesterolLevel: json['cholesterol_level'] as int,
      systolicBloodPressure: json['systolic_blood_pressure'] as int,
      diastolicBloodPressure: json['diastolic_blood_pressure'] as int,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    final dateOfBirthString = DateFormat('yyyy-MM-dd').format(dateOfBirth);

    return {
      'birth_date': dateOfBirthString,
      'height':     heightCm,
      'weight':     weightKg,
      'ap_hi':      systolicBloodPressure,
      'ap_lo':      diastolicBloodPressure,
      'cholesterol_level': cholesterolLevel,
    };
  }
}