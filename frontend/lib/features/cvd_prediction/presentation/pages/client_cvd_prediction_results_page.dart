import 'package:flutter/material.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_text_styles.dart';

class CvdPredictionResultsPage extends StatelessWidget {
  const CvdPredictionResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cvdPredictionController = context.watch<CvdPredictionController>();
    final data = cvdPredictionController.userHealthData!;
    final pred = cvdPredictionController.predictionResult!;

    final riskPct = (pred.prediction).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text('CVD Risk Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Your CVD risk: $riskPct%', style: AppTextStyles.header),
            const SizedBox(height: 24),
            const Text('Data used:', style: AppTextStyles.subheader),
            const SizedBox(height: 12),
            Text('Date of Birth: ${data.dateOfBirth.toLocal().toIso8601String()}'),
            Text('Height: ${data.heightCm} cm'),
            Text('Weight: ${data.weightKg} kg'),
            Text('Systolic BP: ${data.systolicBloodPressure}'),
            Text('Diastolic BP: ${data.diastolicBloodPressure}'),
            Text('Cholesterol: ${data.cholesterolLevel}'),
          ],
        ),
      ),
    );
  }
}