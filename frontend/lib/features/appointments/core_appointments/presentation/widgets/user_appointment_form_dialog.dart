import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/medical_service_dropdown_field.dart';
import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';

import 'date_picker_field.dart';
import 'time_slot_list.dart';

class UserAppointmentFormDialog extends StatefulWidget {
  const UserAppointmentFormDialog({Key? key}) : super(key: key);

  @override
  _UserAppointmentFormDialogState createState() =>
      _UserAppointmentFormDialogState();
}

class _UserAppointmentFormDialogState
    extends State<UserAppointmentFormDialog> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedMedicalServiceId;
  bool _isLoading = true;

  late final Medic _assignedMedic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initLoad());
  }

  Future<void> _initLoad() async {
    final userController = context.read<UserController>();
    await userController.getMyAssignedMedic();

    final maybeMedic = userController.assignedMedic;
    if (maybeMedic == null) {
      Navigator.of(context).pop();
      return;
    }
    _assignedMedic = maybeMedic;

    final medicalServiceController =
        context.read<MedicalServiceController>();
    await medicalServiceController
        .getMedicalServicesForAssignedMedic(_assignedMedic.id);

    context.read<MedicScheduleController>().clear();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _reloadSlots();
    }
  }

  void _reloadSlots() {
    final medicalServiceId = _selectedMedicalServiceId;
    if (medicalServiceId == null) return;

    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<MedicScheduleController>().getFreeTimeSlotsForAssignedMedic(
          isoDate: isoDate,
          medicalServiceId: medicalServiceId,
        );
  }

  Future<void> _assign(TimeSlot slot) async {
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      slot.startDateTime.hour,
      slot.startDateTime.minute,
    );
    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      slot.endDateTime.hour,
      slot.endDateTime.minute,
    );

    final appt = Appointment(
      id: 0,
      userId: 0,
      medicId: _assignedMedic.id,
      medicalServiceId: _selectedMedicalServiceId!,
      address: _assignedMedic.streetAddress,
      appointmentStart: start,
      appointmentEnd: end,
      appointmentStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await context
          .read<UserAppointmentsController>()
          .createAppointment(appt);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicalServiceController =
        context.watch<MedicalServiceController>();
    final scheduleController =
        context.watch<MedicScheduleController>();
    final services =
        medicalServiceController.medicalServices;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 153),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 76),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'New Appointment',
                        style: AppTextStyles.welcomeHeader
                            .copyWith(
                          color: AppColors.primaryRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.white24,
                    ),

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(
                                        AppColors.primaryRed),
                              ),
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .stretch,
                                children: [
                                  DatePickerField(
                                    selectedDate:
                                        _selectedDate,
                                    onTap: _pickDate,
                                  ),
                                  const SizedBox(
                                      height: 16),

                                  MedicalServiceDropdownField(
                                    medicalServices: services,
                                    selectedMedicalServiceId:
                                        _selectedMedicalServiceId,
                                    onChanged: (id) {
                                      setState(() {
                                        _selectedMedicalServiceId =
                                            id;
                                      });
                                      _reloadSlots();
                                    },
                                  ),
                                  const SizedBox(
                                      height: 16),

                                  TimeSlotList(
                                    freeSlots: scheduleController
                                        .freeTimeSlots,
                                    isLoading:
                                        scheduleController
                                            .isLoading,
                                    onSlotTap:
                                        _assign,
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const Divider(
                      height: 1,
                      color: Colors.white24,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}