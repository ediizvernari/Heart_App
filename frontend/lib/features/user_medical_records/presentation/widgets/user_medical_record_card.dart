import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_medical_record.dart';


class UserMedicalRecordCard extends StatelessWidget {
  final UserMedicalRecord userMedicalRecord;

  const UserMedicalRecordCard({
    Key? key,
    required this.userMedicalRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recordedAtLocal = userMedicalRecord.createdAt.toLocal();

    final formattedDate = DateFormat('yyyy-MM-dd').format(recordedAtLocal);
    final formattedTime = DateFormat('HH:mm').format(recordedAtLocal);

    final assignedUserDateOfBirth = userMedicalRecord.birthDate;
    final formattedDateOfBirth = DateFormat('yyyy-MM-dd').format(assignedUserDateOfBirth);

    String cholesterolLabel(int level) {
      switch (level) {
        case 1: return 'Normal';
        case 2: return 'Above normal';
        case 3: return 'Way above normal';
        default: return 'unknown';
      }
    }

    return Card(
      color: AppColors.background,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recorded at: $formattedDate $formattedTime'),
            const SizedBox(height: 8),
            Text('Date of birth: $formattedDateOfBirth'),
            Text('CVD Percentage Risk: ${userMedicalRecord.cvdRiskPercentage}%'),
            Text('Weight (Kg): ${userMedicalRecord.weightKg}'),
            Text('Height (cm): ${userMedicalRecord.heightCm}'),
            Text('Cholesterol Level: ${cholesterolLabel(userMedicalRecord.cholesterolLevel)}'),
            Text('Systolic Blood Pressure: ${userMedicalRecord.systolicBloodPressure}'),
            Text('Diastolic Blood Pressure: ${userMedicalRecord.diastolicBloodPressure}'),
          ],
        ),
      ),
    );
  }
}