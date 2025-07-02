import 'package:flutter/material.dart';
import 'package:frontend/widgets/ekg_signal.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/medics/presentation/widgets/medic_dashboard_panel.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

class MedicMainPage extends StatelessWidget {
  const MedicMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const CustomAppBar(
                      title: 'Welcome!',
                      onBack: null,
                      showBackButton: false,
                    ),

                    Expanded(
                      child: MedicDashboardPanel(
                        onAssignedUsers: () {
                          Navigator.pushNamed(context, '/medic-patients');
                        },
                        onMedicalServices: () {
                          Navigator.pushNamed(context, '/medical-services');
                        },
                        onAppointments: () {
                          Navigator.pushNamed(context, '/medic-appointments');
                        },
                        onAvailability: () {
                          Navigator.pushNamed(context, '/medic-availability');
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: RoundedButton(
                          text: 'Log Out',
                          onPressed: () {
                            context.read<AuthController>().logout(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              EkgSignal(
                data: const <double>[
                  0, 0, 1, -1, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 1, -1, 0],
                bottomOffset: screenHeight * 0.15,
                height: screenHeight * 0.1,
              ),
            ],
          );
        },
      ),
    );
  }
}