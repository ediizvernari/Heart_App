import 'package:flutter/material.dart';
import 'package:frontend/widgets/ekg_signal.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/users/presentation/widgets/user_dashboard_panel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';

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
    final assignmentStatus = context.watch<UserController>().assignmentStatus;
    if (assignmentStatus == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

                    const Expanded(child: UserDashboardPanel()),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: RoundedButton(
                          text: 'Log Out',
                          onPressed: () =>
                              context.read<AuthController>().logout(context),
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