import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/medics/presentation/pages/medic_patients_page.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MedicPatientsPage()),
                    );
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
                      // If your AuthController is provided higher up in the tree:
                      context.read<AuthController>().logout(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}