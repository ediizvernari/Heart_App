import 'package:flutter/material.dart';
import 'package:frontend/features/cvd_prediction/presentation/widgets/minimal_cvd_gauge.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';

class CvdPredictionResultsPage extends StatelessWidget {
  const CvdPredictionResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CvdPredictionController>();

    // dacă încă nu avem date, arătăm loader pe fundalul gradient
    if (ctrl.userHealthData == null || ctrl.predictionResult == null) {
      return Scaffold(
        body: Stack(
          children: [
            // fundal gradient full-screen
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
            // loader centrat în SafeArea
            const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    final value = ctrl.predictionResult!.prediction;
    final pct = value.toStringAsFixed(1);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const CustomAppBar(
                  title: 'CVD Probability Results',
                  showBackButton: true,
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CvdRiskGauge(value: value),
                              const SizedBox(height: 16),
                              Text(
                                'Your estimated CVD probability is $pct%',
                                style: AppTextStyles.header.copyWith(
                                  color: AppColors.cardBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: RoundedButton(
                                      text: 'Go to Home Page',
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/user_home');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: RoundedButton(
                                      text: 'Make an Appointment',
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/user-appointments');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
