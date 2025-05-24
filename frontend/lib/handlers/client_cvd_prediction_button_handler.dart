import 'package:flutter/material.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import 'package:frontend/features/cvd_prediction/presentation/pages/client_cvd_prediction_results_page.dart';
import 'package:frontend/features/user_health_data/presentation/pages/client_personal_data_insertion_page.dart';
import 'package:provider/provider.dart';

import 'package:frontend/utils/ui/dialog_utils.dart';


Future<void> handleCvdPredictionButtonTap(BuildContext context) async {
  final cvdController = context.read<CvdPredictionController>();
  cvdController.clearError();

  await cvdController.getUserHealthDataForPrediction();
  if (!context.mounted) return;

  if (cvdController.userHealthData == null) {
    DialogUtils.showMissingDataDialog(
      context,
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ClientPersonalDataInsertionPage(),
          ),
        );
      },
    );
    return;
  }

  DialogUtils.showHealthDataConfirmationDialog(
    context: context,
    healthData: cvdController.userHealthData!,
    onConfirm: () async {
      Navigator.of(context).pop();

      await cvdController.predictCvdProbability();
      if (!context.mounted) return;

      if (cvdController.error != null) {
        DialogUtils.showAlertDialog(
          context,
          'Error',
          cvdController.error!,
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CvdPredictionResultsPage(),
        ),
      );
    },
  );
}