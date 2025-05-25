import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/rounded_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../user_health_data/presentation/pages/client_personal_data_insertion_page.dart';
import 'package:frontend/handlers/client_cvd_prediction_button_handler.dart';
import 'package:frontend/handlers/available_medics_button_handler.dart';
import '../controllers/user_controller.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  _UserMainPageState createState() => _UserMainPageState();
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

    final bool hasMedic = userController.assignmentStatus!.isAssignedToMedic;

    final _MenuItem predictionItem = _MenuItem(
      icon: Icons.health_and_safety,
      label: 'Predict CVD Risk',
      onTap: () => handleCvdPredictionButtonTap(context),
    );
    final List<_MenuItem> smallMenuItems = [
      _MenuItem(
        icon: Icons.insert_chart,
        label: 'Data Insertion',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ClientPersonalDataInsertionPage(),
          ),
        ),
      ),
      hasMedic
          ? _MenuItem(
              icon: Icons.medical_services,
              label: 'Medic Operations',
              onTap: () => Navigator.pushNamed(context, '/medic-interactions'),
            )
          : _MenuItem(
              icon: Icons.search,
              label: 'Find a Medic',
              onTap: () async {
                await AvailableMedicsButtonHandler.navigateToFindMedicPage(context);
                await context.read<UserController>().getMyAssignmentStatus();
              },
            ),
    ];

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          title: 'Welcome!',
        ),
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
                    children: smallMenuItems
                        .map((item) => Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _ActionCard(
                                  icon: item.icon,
                                  label: item.label,
                                  onTap: item.onTap,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 2,
                    child: _ActionCard(
                      icon: predictionItem.icon,
                      label: predictionItem.label,
                      onTap: predictionItem.onTap,
                      isBig: true,
                    ),
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

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isBig;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isBig = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isBig ? AppColors.primaryRed : Colors.grey[700]!;
    final Color textColor = isBig ? AppColors.primaryRed : Colors.black;
    final double iconSize = isBig ? 64.0 : 48.0;
    final double fontSize = isBig ? 18.0 : 14.0;

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
