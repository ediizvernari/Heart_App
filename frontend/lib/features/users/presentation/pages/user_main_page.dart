import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/user_health_data/presentation/pages/client_personal_data_insertion_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/widgets/action_card.dart';
import 'package:frontend/handlers/client_cvd_prediction_button_handler.dart';
import 'package:frontend/handlers/available_medics_button_handler.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../controllers/user_controller.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().getMyAssignmentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    if (userController.assignmentStatus == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasMedic = userController.assignmentStatus!.isAssignedToMedic;

    final clientDataButton = ActionCard(
      icon: Icons.insert_chart,
      label: 'Enter Health Data',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ClientPersonalDataInsertionPage(),
        ),
      ),
    );

    final medicActionButton = hasMedic
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

    final cvdPredictionButton = ActionCard(
      icon: Icons.health_and_safety,
      label: 'Predict CVD Risk',
      onTap: () => handleCvdPredictionButtonTap(context),
      isPrimary: true,
    );

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(title: 'Welcome!'),
      ),
      backgroundColor: AppColors.primaryRed,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: clientDataButton,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: medicActionButton,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 2,
                    child: cvdPredictionButton,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: RoundedButton(
              text: 'Log Out',
              onPressed: () {
                context.read<AuthController>().logout(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
