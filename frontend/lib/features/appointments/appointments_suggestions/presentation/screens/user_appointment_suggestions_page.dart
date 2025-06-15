import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/widgets/appointment_suggestion_item.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/medical_service/presentation/controllers/medical_service_controller.dart';
import 'package:frontend/features/appointments/appointments_suggestions/presentation/controllers/user_appointment_suggestion_controller.dart';

class UserAppointmentSuggestionsPage extends StatefulWidget {
  const UserAppointmentSuggestionsPage({Key? key}) : super(key: key);

  @override
  _UserAppointmentSuggestionsPageState createState() => _UserAppointmentSuggestionsPageState();
}

class _UserAppointmentSuggestionsPageState extends State<UserAppointmentSuggestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appointmentSuggestionController = context.read<UserAppointmentSuggestionController>();
      final medicalServiceController  = context.read<MedicalServiceController>();

      await appointmentSuggestionController.getMyAppointmentSuggestions();
      final medics = appointmentSuggestionController.myAppointmentSuggestions
          .map((s) => s.medicId)
          .toSet();
      for (final medicId in medics) {
        await medicalServiceController.getMedicalServicesForAssignedMedic(medicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestionCtrl = context.watch<UserAppointmentSuggestionController>();
    final serviceCtrl    = context.watch<MedicalServiceController>();

    if (suggestionCtrl.isLoading || serviceCtrl.loadingServices) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (suggestionCtrl.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error loading suggestions: ${suggestionCtrl.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (serviceCtrl.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error loading services: ${serviceCtrl.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final pending = suggestionCtrl.myAppointmentSuggestions
        .where((s) => s.status == 'pending')
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Appointment Suggestions'),
              Expanded(
                child: pending.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending suggestions.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: pending.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final s = pending[i];
                          return AppointmentSuggestionItem(
                            apppointmentSuggestion: s,
                            onRespond: (id, newStatus) async {
                              await suggestionCtrl.respondToSuggestion(
                                id,
                                newStatus,
                              );
                              if (newStatus == 'accepted') {
                                Navigator.pushNamed(
                                  context,
                                  '/user-appointments',
                                  arguments: {'fromSuggestion': s},
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
