import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/core_appointments/data/models/appointment_request.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/widgets/medical_service_dropdown_field.dart';
import 'package:frontend/features/medics/data/models/medic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/appointments/core_appointments/presentation/controllers/user_appointments_controller.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/appointments/scheduling/presentation/medic_schedule_controller.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';

import 'date_picker_field.dart';
import 'time_slot_list.dart';

class UserAppointmentFormDialog extends StatefulWidget {
  const UserAppointmentFormDialog({Key? key}) : super(key: key);

  @override
  _UserAppointmentFormDialogState createState() =>
      _UserAppointmentFormDialogState();
}

class _UserAppointmentFormDialogState extends State<UserAppointmentFormDialog> {
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

    if (!mounted) return;
    if (maybeMedic == null) {
      Navigator.of(context).pop();
      return;
    }
    _assignedMedic = maybeMedic;

    final medicalServiceController = context.read<MedicalServiceController>();
    await medicalServiceController.getMedicalServicesForAssignedMedic(_assignedMedic.id);

    if (!mounted) return;
    context.read<MedicScheduleController>().clear();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _reloadSlots();
    }
  }

  void _reloadSlots() {
    final medicalServiceId = _selectedMedicalServiceId;
    if (medicalServiceId == null) return;

    final targetDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<MedicScheduleController>().getFreeTimeSlotsForAssignedMedic(targetDate: targetDate, medicalServiceId: medicalServiceId);
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

    final appointmentRequest = AppointmentRequest(
      medicId: _assignedMedic.id,
      medicalServiceId: _selectedMedicalServiceId!,
      address: _assignedMedic.streetAddress,
      appointmentStart: start,
      appointmentEnd: end,
    );

    try {
      await context.read<UserAppointmentsController>().createAppointment(appointmentRequest);
      if (!mounted) return;
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
    final medicalServiceController = context.watch<MedicalServiceController>();
    final scheduleController = context.watch<MedicScheduleController>();
    final medicalServices = medicalServiceController.medicalServices;

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cardBackground,
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
                          color: AppColors.primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.background,
                    ),

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(
                                        AppColors.primaryBlue),
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
                                    medicalServices: medicalServices,
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
                      color: AppColors.background,
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
                              color: AppColors.primaryBlue,
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