import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import 'package:frontend/features/user_health_data/presentation/pages/user_health_data_insertion_page.dart';
import 'package:frontend/features/cvd_prediction/presentation/pages/client_cvd_prediction_results_page.dart';

Future<void> handleCvdPredictionTap(BuildContext context) async {
  final cvdController = context.read<CvdPredictionController>();
  cvdController.clearError();

  await cvdController.getUserHealthDataForPrediction();
  if (!context.mounted) return;

  if (cvdController.userHealthData == null) {
    final goEnter = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Missing Health Data'),
        content: const Text(
          'We need your health data to make a prediction.\n'
          'Would you like to enter it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(true),
            child: const Text('Enter Data'),
          ),
        ],
      ),
    );
    if (goEnter == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserHealthDataPage()),
      );
    }
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dlgCtx) {
      final hd = cvdController.userHealthData!;
      return AlertDialog(
        title: const Text('Confirm Your Data'),
        content: Text(
          'Date of birth: ${hd.dateOfBirth}\n'
          'Height: ${hd.heightCm} cm\n'
          'Weight: ${hd.weightKg} kg\n'
          'Systolic Blood Pressure: ${hd.systolicBloodPressure} mmHg\n'
          'Diastolic Blood Pressure: ${hd.diastolicBloodPressure} mmHg\n'
          'Cholesterol: ${hd.cholesterolLevel} mg/dL',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(true),
            child: const Text('Predict'),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;

  await cvdController.predictCvdProbability();
  if (!context.mounted) return;

  if (cvdController.error != null) {
    await showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Error'),
        content: Text(cvdController.error!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  if (context.mounted) {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CvdPredictionResultsPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        opaque: true,
      ),
    );
  }
}