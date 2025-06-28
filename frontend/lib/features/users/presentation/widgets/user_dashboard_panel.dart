import 'package:flutter/material.dart';
import 'package:frontend/features/cvd_prediction/presentation/controllers/cvd_prediction_controller.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/widgets/action_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserDashboardPanel extends StatelessWidget {
  const UserDashboardPanel({Key? key}) : super(key: key);

  Future<void> _onPredictCvdRiskPressed(BuildContext context) async {
    final cvdController = context.read<CvdPredictionController>();
    cvdController.clearError();

    await cvdController.getUserHealthDataForPrediction();
    if (!context.mounted) return;

    if (cvdController.userHealthData == null) {
      final goEnter = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Missing Health Data'),
          content: const Text(
            'We need your health data to make a prediction.\n'
            'Would you like to enter it now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enter Data'),
            ),
          ],
        ),
      );
      if (goEnter == true && context.mounted) {
        Navigator.of(context).pushNamed('/user-health-data-insertion');
      }
      return;
    }

    String cholesterolText(int lvl) {
      switch (lvl) {
        case 1:
          return 'Normal';
        case 2:
          return 'Above average';
        case 3:
          return 'Way above average';
        default:
          return 'Unknown';
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final userHealthData = cvdController.userHealthData!;
        return AlertDialog(
          title: const Text('Confirm Your Data'),
          content: Text(
            'Date of birth: ${DateFormat('yyyy-MM-dd').format(userHealthData.dateOfBirth)}\n'
            'Height: ${userHealthData.heightCm} cm\n'
            'Weight: ${userHealthData.weightKg} kg\n'
            'Systolic Blood Pressure: ${userHealthData.systolicBloodPressure} mmHg\n'
            'Diastolic Blood Pressure: ${userHealthData.diastolicBloodPressure} mmHg\n'
            'Cholesterol Level: ${cholesterolText(userHealthData.cholesterolLevel)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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
        builder: (dialogContext) => AlertDialog(
          title: const Text('Error'),
          content: Text(cvdController.error!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (context.mounted) {
      await Navigator.of(context).pushNamed('/prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final hasMedic = userController.assignmentStatus!.isAssignedToMedic;

    final enterDataCard = ActionCard(
      icon: Icons.insert_chart,
      label: 'Enter Health Data',
      onTap: () => Navigator.of(context).pushNamed('/user-health-data-insertion'),
    );

    final medicOpsCard = hasMedic
        ? ActionCard(
            icon: Icons.medical_services,
            label: 'Medic Operations',
            onTap: () => Navigator.pushNamed(context, '/medic-interactions'),
          )
        : ActionCard(
            icon: Icons.search,
            label: 'Find a Medic',
            onTap: () async {
              final userController = context.read<UserController>();
              await Navigator.of(context).pushNamed('/find-medic');
              await userController.getMyAssignmentStatus();
            },
          );

    final predictCvdCard = ActionCard(
      icon: Icons.health_and_safety,
      label: 'CVD Probability',
      isPrimary: true,
      onTap: () async {
        try {
          await _onPredictCvdRiskPressed(context);
        } catch (e, st) {
          debugPrint('Error in CVD prediction flow: $e\n$st');
        }
      },
    );

    final recordsCard = ActionCard(
      icon: Icons.folder_shared,
      label: 'My Medical Records',
      onTap: () => Navigator.pushNamed(context, '/user_records'),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: enterDataCard),
              const SizedBox(width: 16),
              Expanded(child: medicOpsCard),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: predictCvdCard),
              const SizedBox(width: 16),
              Expanded(child: recordsCard),
            ],
          ),
        ],
      ),
    );
  }
}
