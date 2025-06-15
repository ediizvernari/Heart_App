import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/data/models/appointment_suggestion_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/medical_service/data/models/medical_service.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

typedef SuggestionResponseCallback = void Function(int suggestionId, String newStatus);

class AppointmentSuggestionItem extends StatelessWidget {
  final AppointmentSuggestion apppointmentSuggestion;
  final SuggestionResponseCallback? onRespond;

  const AppointmentSuggestionItem({
    Key? key,
    required this.apppointmentSuggestion,
    this.onRespond,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final svcCtl = context.watch<MedicalServiceController>();

    final service = svcCtl.medicalServices.firstWhere(
      (s) => s.id == apppointmentSuggestion.medicalServiceId,
      orElse: () => MedicalService(
        id: 0,
        medicId: 0,
        medicalServiceTypeId: 0,
        name: 'Unknown Service',
        price: 0,
        durationMinutes: 0,
      ),
    );

    final fmtDate = DateFormat.yMMMd().add_jm().format(apppointmentSuggestion.createdAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: AppTextStyles.welcomeHeader.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Reason: ${apppointmentSuggestion.reason}',
              style: AppTextStyles.buttonText,
            ),
            const SizedBox(height: 4),
            Text(
              'Suggested on: $fmtDate',
              style: AppTextStyles.buttonText.copyWith(fontSize: 12),
            ),
            if (onRespond != null) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => onRespond!(apppointmentSuggestion.id, 'accepted'),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => onRespond!(apppointmentSuggestion.id, 'declined'),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
