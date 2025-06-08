import 'package:flutter/material.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/appointments_panel.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/controllers/medic_appointments_controller.dart';


class MedicAppointmentsPage extends StatefulWidget {
  const MedicAppointmentsPage({Key? key}) : super(key: key);

  @override
  _MedicAppointmentsPageState createState() => _MedicAppointmentsPageState();
}

class _MedicAppointmentsPageState extends State<MedicAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicAppointmentsController>().getMedicAppointments();
      context.read<MedicalServiceController>().getMyMedicalServices();
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
              CustomAppBar(title: 'Patient Appointments'),
              Expanded(child: AppointmentsPanel()),
            ],
          ),
        ),
      ),
    );
  }
}