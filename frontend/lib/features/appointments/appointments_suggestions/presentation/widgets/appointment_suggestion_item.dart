import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/data/models/appointment_suggestion_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/medical_services/data/models/medical_service.dart';
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
    final medicalServiceController = context.watch<MedicalServiceController>();

    final service = medicalServiceController.medicalServices.firstWhere(
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
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'Reason: ${apppointmentSuggestion.reason}',
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 4),
            Text(
              'Suggested on: $fmtDate',
              style: AppTextStyles.cardSubtitle,
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
