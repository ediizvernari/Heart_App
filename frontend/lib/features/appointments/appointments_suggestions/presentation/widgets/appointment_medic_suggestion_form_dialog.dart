import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/medic_appointment_suggestion_controller.dart';
import '../../../../medical_services/presentation/controllers/medical_service_controller.dart';
import '../../data/models/appointment_suggestion_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class SuggestionFormDialog extends StatefulWidget {
  final int userId;

  const SuggestionFormDialog({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  _SuggestionFormDialogState createState() => _SuggestionFormDialogState();
}

class _SuggestionFormDialogState extends State<SuggestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _medicalServiceId;
  String _reason = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicalServiceController = context.read<MedicalServiceController>();
      medicalServiceController.getMyMedicalServices().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicAppointmentSuggestionController = context.read<MedicAppointmentSuggestionController>();
    final medicalServiceController = context.watch<MedicalServiceController>();
    final medicalServices = medicalServiceController.medicalServices;

    final bool canSend = _medicalServiceId != null;

    return AlertDialog(
      scrollable: true,
      backgroundColor: AppColors.background,
      title: const Text(
        'Suggest Appointment',
        style: AppTextStyles.welcomeHeader,
      ),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            isExpanded: true,
            value: _medicalServiceId,
            decoration: const InputDecoration(labelText: 'Medical Service'),
            items: medicalServices
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ))
                .toList(),
            hint: const Text('Select Medical Service'),
            validator: (v) => v == null ? 'Required' : null,
            onChanged: (v) => setState(() => _medicalServiceId = v),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
            maxLines: 3,
            onSaved: (v) => _reason = v?.trim() ?? '',
            style: const TextStyle(color: AppColors.textPrimary), 
          ),
        ]),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: AppColors.primaryBlue)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          onPressed: canSend
              ? () {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  final medicalService = medicalServices.firstWhere((s) => s.id == _medicalServiceId!);

                  final suggestion = AppointmentSuggestion(
                    id: 0,
                    userId: widget.userId,
                    medicId: medicalService.medicId,
                    medicalServiceId: _medicalServiceId!,
                    status: 'pending',
                    reason: _reason,
                    createdAt: DateTime.now(),
                  );

                  final pop = Navigator.of(context).pop;
                  medicAppointmentSuggestionController.createSuggestion(suggestion).then((_) {
                    if (!mounted) return;
                    pop();
                  });
                }
              : null,
          child: const Text('Send', style: TextStyle(color: AppColors.background)),
        ),
      ],
    );
  }
}
