import 'package:flutter/material.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/handlers/client_cvd_prediction_button_handler.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/action_card.dart';
import 'package:frontend/handlers/available_medics_button_handler.dart';
import 'package:frontend/features/user_health_data/presentation/pages/user_health_data_insertion_page.dart';

class UserDashboardPanel extends StatelessWidget {
  const UserDashboardPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    final hasMedic = userController.assignmentStatus!.isAssignedToMedic;

    final enterDataCard = ActionCard(
      icon: Icons.insert_chart,
      label: 'Enter Health Data',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UserHealthDataPage(),
        ),
      ),
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
              await AvailableMedicsButtonHandler.navigateToFindMedicPage(context);
              await context.read<UserController>().getMyAssignmentStatus();
            },
          );

    final predictCvdCard = ActionCard(
      icon: Icons.health_and_safety,
      label: 'Predict CVD Risk',
      onTap: () => CvdPredictionHandler.handleTap(context),
      isPrimary: true,
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

          SizedBox(
            width: double.infinity,
            child: predictCvdCard,
          ),
        ],
      ),
    );
  }
}
