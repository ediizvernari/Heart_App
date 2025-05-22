import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../controllers/user_controller.dart';
import '../controllers/user_appointments_controller.dart';
import '../../../scheduling/presentation/medic_schedule_controller.dart';
import '../../../../medical_service/presentation/controllers/medical_service_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../widgets/appointment_item.dart';
import '../widgets/user_appointment_form_dialog.dart';

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
    final userCtl = context.read<UserController>();
    final apptCtl = context.watch<UserAppointmentsController>();
    final svcCtl  = context.read<MedicalServiceController>();
    final slotCtl = context.read<MedicScheduleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments', style: AppTextStyles.welcomeHeader),
        backgroundColor: AppColors.primaryRed,
      ),
      body: apptCtl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : apptCtl.error != null
              ? Center(child: Text('Error: ${apptCtl.error}'))
              : apptCtl.myAppointments.isEmpty
                  ? const Center(child: Text('No appointments yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: apptCtl.myAppointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => AppointmentItem(
                        appointment: apptCtl.myAppointments[i],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: userCtl),
                ChangeNotifierProvider.value(value: apptCtl),
                ChangeNotifierProvider.value(value: svcCtl),
                ChangeNotifierProvider.value(value: slotCtl),
              ],
              child: const UserAppointmentFormDialog(),
            ),
          );
        },
      ),
    );
  }
}