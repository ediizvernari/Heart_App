import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/appointment_item.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/user_appointment_form_dialog.dart';
import 'package:frontend/features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';

class UserAppointmentsPanel extends StatefulWidget {
  const UserAppointmentsPanel({Key? key}) : super(key: key);

  @override
  _UserAppointmentsPanelState createState() => _UserAppointmentsPanelState();
}

class _UserAppointmentsPanelState extends State<UserAppointmentsPanel> {
  String _selectedAppointmentStatus = 'pending';

  static const Map<String, String> _statusMap = {
    'Pending': 'pending',
    'Confirmed': 'confirmed',
    'Cancelled': 'cancelled',
    'Completed': 'completed',
  };

  @override
  Widget build(BuildContext context) {
    final appointmentController = context.watch<UserAppointmentsController>();

    if (appointmentController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointmentController.error != null) {
      return Center(
        child: Text(
          'Error: ${appointmentController.error}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final filtered = appointmentController.myAppointments
        .where((a) => a.appointmentStatus == _selectedAppointmentStatus)
        .toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusMap.entries.map((entry) {
                    final label = entry.key;
                    final appointmentStatusKey = entry.value;
                    final isSelected = (_selectedAppointmentStatus == appointmentStatusKey);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,

                        backgroundColor: AppColors.primaryRed,
                        selectedColor: AppColors.primaryRed,

                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),

                        showCheckmark: false,

                        onSelected: (_) {
                          setState(() {
                            _selectedAppointmentStatus = appointmentStatusKey;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Center(
                  child: Text(
                    'No ${_selectedAppointmentStatus[0].toUpperCase()}${_selectedAppointmentStatus.substring(1)} appointments',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => AppointmentItem(
                      appointment: filtered[i],
                    ),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryRed,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              final userController = context.read<UserController>();
              final medicalServiceController = context.read<MedicalServiceController>();
              final medicScheduleController = context.read<MedicScheduleController>();

              showDialog(
                context: context,
                builder: (dialogContext) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: userController),
                      ChangeNotifierProvider.value(value: appointmentController),
                      ChangeNotifierProvider.value(value: medicalServiceController),
                      ChangeNotifierProvider.value(value: medicScheduleController),
                    ],
                    child: const UserAppointmentFormDialog(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
