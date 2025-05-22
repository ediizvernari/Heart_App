import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/appointment_model.dart';
import '../../../../../models/medic.dart';
import '../controllers/user_appointments_controller.dart';
import '../../../scheduling/presentation/medic_schedule_controller.dart';
import '../../../../../controllers/user_controller.dart';
import '../../../../medical_service/presentation/controllers/medical_service_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class UserAppointmentFormDialog extends StatefulWidget {
  const UserAppointmentFormDialog({Key? key}) : super(key: key);

  @override
  _UserAppointmentFormDialogState createState() => _UserAppointmentFormDialogState();
}

class _UserAppointmentFormDialogState extends State<UserAppointmentFormDialog> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedServiceId;
  Medic? _assignedMedic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  Future<void> _initLoad() async {
    final userController = context.read<UserController>();
    final medicalServiceController = context.read<MedicalServiceController>();
    final medicScheduleController = context.read<MedicScheduleController>();

    await userController.fetchAssignedMedic();
    final medic = userController.assignedMedic;
    if (medic != null) {
      await medicalServiceController.getMedicalServicesForAssignedMedic(medic.id);
    }
    medicScheduleController.clear();
    setState(() {
      _assignedMedic = medic;
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _reloadSlots();
    }
  }

  void _reloadSlots() {
    final svcId = _selectedServiceId;
    final medic = _assignedMedic;
    if (svcId == null || medic == null) return;
    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<MedicScheduleController>().getFreeTimeSlotsForAssignedMedic(
      isoDate: isoDate,
      medicalServiceId: svcId,
    );
  }

  Future<void> _assign(Appointment appt) async {
    try {
      await context.read<UserAppointmentsController>().createAppointment(appt);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final medicalServiceController = context.watch<MedicalServiceController>();
    final shceduleController = context.watch<MedicScheduleController>();
    final services = medicalServiceController.medicalServices;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('New Appointment', style: AppTextStyles.welcomeHeader),
            ),
            const Divider(height: 1),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Select Date'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat.yMMMMd().format(_selectedDate)),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (services.isEmpty)
                      const Text('No services available for assigned medic')
                    else
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Select Service'),
                        isExpanded: true,
                        value: _selectedServiceId,
                        items: services.map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} - \$${s.price}'),
                          ),
                        ).toList(),
                        onChanged: (id) {
                          setState(() => _selectedServiceId = id);
                          _reloadSlots();
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    const SizedBox(height: 16),

                    if (shceduleController.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (shceduleController.freeTimeSlots.isEmpty)
                      const Text('No available slots', style: TextStyle(color: Colors.grey))
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          itemCount: shceduleController.freeTimeSlots.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, i) {
                            final slot = shceduleController.freeTimeSlots[i];
                            final m = _assignedMedic!;
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

                            final label = DateFormat.jm().format(start);
                            final appt = Appointment(
                              id: 0,
                              userId: 0,
                              medicId: m.id,
                              medicalServiceId: _selectedServiceId!,
                              address: m.streetAddress,
                              appointmentStart: start,
                              appointmentEnd: end,
                              appointmentStatus: 'pending',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            return ListTile(
                              title: Text(label),
                              subtitle: Text(
                                '${m.streetAddress}, ${m.city}, ${m.country}',
                                style: AppTextStyles.buttonText,
                              ),
                              onTap: () => _assign(appt),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child:
                        const Text('Cancel', style: TextStyle(color: AppColors.primaryRed)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}