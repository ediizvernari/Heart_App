import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_medical_record.dart';


class UserMedicalRecordCard extends StatelessWidget {
  final UserMedicalRecord assignedUserMedicalRecord;

  const UserMedicalRecordCard({
    Key? key,
    required this.assignedUserMedicalRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localTime = assignedUserMedicalRecord.createdAt.toLocal();
    final formattedTime = DateFormat('HH:mm').format(localTime);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recorded at: $formattedTime'),
            const SizedBox(height: 8),
            Text('CVD Percentage Risk: ${assignedUserMedicalRecord.cvdRiskPercentage}'),
            Text('Weight (Kg): ${assignedUserMedicalRecord.weightKg}'),
            Text('Height (cm): ${assignedUserMedicalRecord.heightCm}'),
            Text('Cholesterol Level: ${assignedUserMedicalRecord.cholesterolLevel}'),
            Text('Systolic Blood Pressure: ${assignedUserMedicalRecord.systolicBloodPressure}'),
            Text('Diastolic Blood Pressure: ${assignedUserMedicalRecord.diastolicBloodPressure}'),
          ],
        ),
      ),
    );
  }
}