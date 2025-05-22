import 'package:flutter/material.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:provider/provider.dart';

import '../controllers/medic_appointments_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../widgets/appointment_item.dart';

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
    final medicAppointmentsController = context.watch<MedicAppointmentsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Appointments', style: AppTextStyles.welcomeHeader),
        backgroundColor: AppColors.primaryRed,
      ),
      body: medicAppointmentsController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : medicAppointmentsController.error != null
              ? Center(child: Text('Error: ${medicAppointmentsController.error}'))
              : medicAppointmentsController.medicAppointments.isEmpty
                  ? const Center(child: Text('No patient appointments.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: medicAppointmentsController.medicAppointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final appt = medicAppointmentsController.medicAppointments[i];
                        return AppointmentItem(
                          appointment: appt,
                          onUpdateStatus: (newStatus) {
                            medicAppointmentsController.updateAppointmentStatus(appt.id, newStatus);
                          },
                        );
                      },
                    ),
    );
  }
}