import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/medic_appointment_suggestion_controller.dart';
import '../../../../medical_service/presentation/controllers/medical_service_controller.dart';
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
  int? _serviceId;
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

    final bool canSend = _serviceId != null;

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: const Text(
        'Suggest Appointment',
        style: AppTextStyles.welcomeHeader,
      ),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            isExpanded: true,
            value: _serviceId,
            decoration: const InputDecoration(labelText: 'Medical Service'),
            items: medicalServices
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ))
                .toList(),
            hint: const Text('Select Medical Service'),
            validator: (v) => v == null ? 'Required' : null,
            onChanged: (v) => setState(() => _serviceId = v),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
            maxLines: 3,
            onSaved: (v) => _reason = v?.trim() ?? '',
          ),
        ]),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: AppColors.primaryRed)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
          onPressed: canSend
              ? () {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  final service = medicalServices.firstWhere((s) => s.id == _serviceId!);

                  final suggestion = AppointmentSuggestion(
                    id: 0,
                    userId: widget.userId,
                    medicId: service.medicId,
                    medicalServiceId: _serviceId!,
                    status: 'pending',
                    reason: _reason,
                    createdAt: DateTime.now(),
                  );

                  medicAppointmentSuggestionController.createSuggestion(suggestion).then((_) {
                    Navigator.pop(context);
                  });
                }
              : null,
          child: const Text('Send', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
