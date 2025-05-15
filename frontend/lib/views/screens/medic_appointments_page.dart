import 'package:flutter/material.dart';
import 'package:frontend/controllers/medical_service_controller.dart';
import 'package:provider/provider.dart';

import '../../controllers/medic_appointments_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/appointment_item.dart';

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
      context.read<MedicAppointmentsController>().loadMedicAppointments();
      context.read<MedicalServiceController>().loadMedicalServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctl = context.watch<MedicAppointmentsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Appointments', style: AppTextStyles.welcomeHeader),
        backgroundColor: AppColors.primaryRed,
      ),
      body: ctl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctl.error != null
              ? Center(child: Text('Error: ${ctl.error}'))
              : ctl.medicAppointments.isEmpty
                  ? const Center(child: Text('No patient appointments.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: ctl.medicAppointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final appt = ctl.medicAppointments[i];
                        return AppointmentItem(
                          appointment: appt,
                          onUpdateStatus: (newStatus) {
                            ctl.updateAppointmentStatus(appt.id, newStatus);
                          },
                        );
                      },
                    ),
    );
  }
}