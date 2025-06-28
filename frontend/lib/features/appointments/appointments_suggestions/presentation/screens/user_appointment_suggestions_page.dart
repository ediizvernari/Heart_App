import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/widgets/user_appointment_suggestions_body.dart';
import 'package:provider/provider.dart';

import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/controllers/user_appointment_suggestion_controller.dart';
import 'package:frontend/features/medical_services/presentation/controllers/medical_service_controller.dart';

class UserAppointmentSuggestionsPage extends StatefulWidget {
  const UserAppointmentSuggestionsPage({Key? key}) : super(key: key);

  @override
  State<UserAppointmentSuggestionsPage> createState() => _UserAppointmentSuggestionsPageState();
}

class _UserAppointmentSuggestionsPageState extends State<UserAppointmentSuggestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userAppointmentSuggestionController = context.read<UserAppointmentSuggestionController>();
      final medicalServiceController = context.read<MedicalServiceController>();

      await userAppointmentSuggestionController.getMyAppointmentSuggestions();
      final medics = userAppointmentSuggestionController.myAppointmentSuggestions
          .map((s) => s.medicId)
          .toSet();
      for (final medicId in medics) {
        await medicalServiceController.getMedicalServicesForAssignedMedic(medicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: 'Appointment Suggestions'),
              Expanded(child: UserAppointmentSuggestionsBody()),
            ],
          ),
        ),
      ),
    );
  }
}