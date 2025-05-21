import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/appointment_suggestion_model.dart';
import '../../../../../controllers/medical_service_controller.dart';
import '../../../../../models/medical_service.dart';
import '../../../../../core/constants/app_text_styles.dart';

typedef SuggestionResponseCallback = void Function(int suggestionId, String newStatus);

class SuggestionItem extends StatelessWidget {
  final AppointmentSuggestion suggestion;
  final SuggestionResponseCallback? onRespond;

  const SuggestionItem({
    required this.suggestion,
    this.onRespond,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final svcCtl = context.watch<MedicalServiceController>();

    final service = svcCtl.services.firstWhere(
      (s) => s.id == suggestion.medicalServiceId,
      orElse: () => MedicalService(
        id: 0,
        medicId: 0,
        medicalServiceTypeId: 0,
        name: 'Unknown Service',
        price: 0,
        durationMinutes: 0,
      ),
    );

    final fmtDate = DateFormat.yMMMd().add_jm().format(suggestion.createdAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
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
              'Reason: ${suggestion.reason}',
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
                    onPressed: () => onRespond!(suggestion.id, 'accepted'),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => onRespond!(suggestion.id, 'declined'),
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
