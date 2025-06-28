import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';

import '../controllers/user_appointments_controller.dart';
import '../controllers/medic_appointments_controller.dart';

import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import '../widgets/user_appointment_form_dialog.dart';
import '../widgets/appointment_item.dart';

class AppointmentsPanel extends StatefulWidget {
  const AppointmentsPanel({Key? key}) : super(key: key);

  @override
  _AppointmentsPanelState createState() => _AppointmentsPanelState();
}

class _AppointmentsPanelState extends State<AppointmentsPanel> {
  String _selectedStatus = 'pending';

  static const Map<String, String> _statusMap = {
    'Pending': 'pending',
    'Confirmed': 'confirmed',
    'Cancelled': 'cancelled',
    'Completed': 'completed',
  };

  @override
  Widget build(BuildContext context) {
    MedicAppointmentsController? medicController;
    UserAppointmentsController? userController;

    try {
      medicController = context.watch<MedicAppointmentsController>();
    } catch (_) {
      medicController = null;
    }
    try {
      userController = context.watch<UserAppointmentsController>();
    } catch (_) {
      userController = null;
    }

    final bool isMedic = medicController != null;
    final bool isUser = userController != null;

    if (!isMedic && !isUser) {
      return Center(
        child: Text(
          'No appointments controller found',
          style: AppTextStyles.dialogContent.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    final appointments = isMedic
        ? medicController.medicAppointments
        : userController!.myAppointments;
    final isLoading = isMedic
        ? medicController.isLoading
        : userController!.isLoading;
    final error = isMedic
        ? medicController.error
        : userController!.error;

    final filtered = appointments
        .where((a) => a.appointmentStatus == _selectedStatus)
        .toList();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _statusMap.entries.map((entry) {
                  final label = entry.key;
                  final statusKey = entry.value;
                  final isSelected = (_selectedStatus == statusKey);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        label,
                        style: AppTextStyles.subheader.copyWith(
                          color: isSelected ? AppColors.background : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.softGrey,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = statusKey;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            if (isLoading) ...[
              const Expanded(child: Center(child: CircularProgressIndicator()))
            ] else if (error != null) ...[
              Expanded(
                child: Center(
                  child: Text(
                    'Error: $error',
                    style: AppTextStyles.dialogContent.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              )
            ] else if (filtered.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Text(
                    'No ${_selectedStatus[0].toUpperCase()}${_selectedStatus.substring(1)} appointments.',
                    style: AppTextStyles.dialogContent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
            ] else ...[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final appointment = filtered[index];
                    return AppointmentItem(
                      appointment: appointment,
                      isMedicView: isMedic,
                      onUpdateStatus: isMedic
                          ? (newStatus) => medicController!.updateAppointmentStatus(
                                appointment.id,
                                newStatus,
                              )
                          : (appointment.appointmentStatus == 'pending' || appointment.appointmentStatus == 'confirmed')
                            ? (newStatus) => userController?.updateAppointmentStatus(appointment.id, newStatus)
                            : null,
                    );
                  },
                ),
              ),
            ],
          ],
        ),

        if (isUser)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: AppColors.background),
              onPressed: () {
                final userController = context.read<UserController>();
                final medicalServiceController = context.read<MedicalServiceController>();
                final medicScheduleController = context.read<MedicScheduleController>();
                final appointmentController = context.read<UserAppointmentsController>();

                showDialog(
                  context: context,
                  builder: (dialogCtx) {
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