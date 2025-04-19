import 'package:flutter/material.dart';
import '../controllers/client_cvd_controller.dart';
import '../views/screens/client_cvd_prediction_results_page.dart';
import '../views/screens/client_personal_data_insertion_page.dart';
import '../utils/ui/dialog_utils.dart';

Future<void> handleCVDPredictionButtonTap(BuildContext context, String? token) async {
  if (token == null || !context.mounted) return;

  final controller = ClientCVDController();

  try {
    final healthData = await controller.getUserHealthDataForPrediction(token);

    if (!context.mounted) return;

    if (healthData != null) {
      DialogUtils.showHealthDataConfirmationDialog(
        context: context,
        healthData: healthData,
        onConfirm: () async {
          final prediction = await controller.getPredictedCVDProbability(token);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientCVDPredictionResultsPage(
                healthData: healthData,
                predictedProbability: prediction,
              ),
            ),
          );
        },
      );
    } else {
      DialogUtils.showMissingDataDialog(
        context,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientPersonalDataInsertionPage(),
            ),
          );
        },
      );
    }
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: ${e.toString()}")),
    );
  }
}
