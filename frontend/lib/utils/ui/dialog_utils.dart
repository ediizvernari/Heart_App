import 'package:flutter/material.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:intl/intl.dart';

class DialogUtils {
  static void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      )
    );
  }

  static Future<void> showHealthDataConfirmationDialog({
    required BuildContext context,
    required UserHealthData healthData,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Health Data For Prediction"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Date of Birth: ${DateFormat('dd/MM/yyyy').format(healthData.dateOfBirth)}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Height (cm): ${healthData.heightCm}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Weight (kg): ${healthData.weightKg}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Systolic BP: ${healthData.systolicBloodPressure}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Diastolic BP: ${healthData.diastolicBloodPressure}"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("Cholesterol Level: ${healthData.cholesterolLevel}"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text("Confirm & View Prediction Results"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            )
          ],
        );
      },
    );
  }

  static Future<void> showMissingDataDialog(BuildContext context, VoidCallback onProceed) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Health Data Required"),
          content: const Text("You need to insert your health data before receiving a prediction."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text("Proceed to Data Insertion"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onProceed();
              },
            ),
          ],
        );
      },
    );
  }
}
