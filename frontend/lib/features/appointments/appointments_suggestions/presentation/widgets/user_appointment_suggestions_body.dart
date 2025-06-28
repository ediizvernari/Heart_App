import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/widgets/appointment_suggestion_item.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/controllers/user_appointment_suggestion_controller.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';

class UserAppointmentSuggestionsBody extends StatefulWidget {
  const UserAppointmentSuggestionsBody({Key? key}) : super(key: key);

  @override
  _UserAppointmentSuggestionsBodyState createState() => _UserAppointmentSuggestionsBodyState();
}

class _UserAppointmentSuggestionsBodyState extends State<UserAppointmentSuggestionsBody> {
  @override
  Widget build(BuildContext context) {
    final userAppointmentSuggestionController = context.watch<UserAppointmentSuggestionController>();
    final medicalServiceController = context.watch<MedicalServiceController>();

    if (userAppointmentSuggestionController.isLoading || medicalServiceController.loadingServices) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = userAppointmentSuggestionController.error ?? medicalServiceController.error;
    if (error != null) {
      return Center(
        child: Text('Error: $error', style: AppTextStyles.errorText),
      );
    }

    final pending = userAppointmentSuggestionController.myAppointmentSuggestions
        .where((s) => s.status == 'pending')
        .toList();

    if (pending.isEmpty) {
      return const Center(
        child: Text(
          'No pending suggestions.',
          style: AppTextStyles.heading1,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = pending[i];
        return AppointmentSuggestionItem(
          apppointmentSuggestion: s,
          onRespond: (id, newStatus) async {
            final navigator = Navigator.of(context);

            await userAppointmentSuggestionController.respondToSuggestion(id, newStatus);
            if (!mounted) return;

            if (newStatus == 'accepted') {
              navigator.pushNamed(
                '/user-appointments',
                arguments: {'fromSuggestion': s},
              );
            }
          },
        );
      },
    );
  }
}