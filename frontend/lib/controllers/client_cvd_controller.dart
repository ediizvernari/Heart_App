import 'package:flutter/material.dart';
import 'package:frontend/utils/network_utils.dart';
import 'package:frontend/screens/client_personal_data_insertion_page.dart';
import 'package:frontend/screens/client_cvd_prediction_results_page.dart';

Future<void> handleCVDPredictionButtonTap(BuildContext context, String? token) async {
  try {
    // Check if the user has enough health data for prediction
    final bool userHasHealthDataForPrediction = await checkUserHasHealthData(token);

    if (!context.mounted) return;

    if (userHasHealthDataForPrediction) {
      // Fetch the health data to be used for prediction
      final Map<String, dynamic> healthDataUsedForPrediction = await fetchUserHealthDataDataForPrediction(token);

      if (!context.mounted) return;

      // Show confirmation dialog with the user's health data
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm Health Data For Prediction"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: healthDataUsedForPrediction.entries.map((entry) {
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

                  // Fetch the predicted percentage
                  final double predictedProbability = await getCVDPredictionPercentage(token);

                  if (!context.mounted) return;

                  // Navigate to the results page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientCVDPredictionResultsPage(
                        healthData: healthDataUsedForPrediction,
                        predictedProbability: predictedProbability,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      // Show a prompt to the user if no health data is available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Health Data Required"),
            content: const Text("You need to insert your health data before receiving a prediction."),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text("Proceed to Data Insertion"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientPersonalDataInsertionPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    if (!context.mounted) return;

    // Show an error message if something goes wrong
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: ${e.toString()}")),
    );
  }
}
