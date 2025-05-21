import 'package:flutter/material.dart';

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
    required Map<String, dynamic> healthData,
    required VoidCallback onConfirm,
  }) {
    return showDialog (
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Health Data For Prediction"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: healthData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("${entry.key}: ${entry.value}"),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text("Confirm & View Prediction Results"),
              onPressed: () async {
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
