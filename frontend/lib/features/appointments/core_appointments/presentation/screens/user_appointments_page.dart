import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/appointments_panel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({Key? key}) : super(key: key);

  @override
  _UserAppointmentsPageState createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAppointmentsController>().getMyAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'My Appointments'),
              Expanded(child: AppointmentsPanel()),
            ],
          ),
        ),
      ),
    );
  }
}
