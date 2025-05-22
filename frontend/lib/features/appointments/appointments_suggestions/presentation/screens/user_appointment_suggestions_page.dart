import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/user_appointment_suggestion_controller.dart';
import '../../../../medical_service/presentation/controllers/medical_service_controller.dart';
import '../widgets/appointment_suggestion_item.dart';
import '../../../../../core/constants/app_colors.dart';


//TODO: ADD an are you sure button
class UserSuggestionsPage extends StatefulWidget {
  const UserSuggestionsPage({super.key});
  @override
  _UserSuggestionsPageState createState() => _UserSuggestionsPageState();
}

class _UserSuggestionsPageState extends State<UserSuggestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appointmentSuggestionController = context.read<UserAppointmentSuggestionController>();
      final medicalServiceController  = context.read<MedicalServiceController>();

      await appointmentSuggestionController.getMyAppointmentSuggestions();

      final medics = appointmentSuggestionController.myAppointmentSuggestions.map((s) => s.medicId).toSet();
      for (final medicId in medics) {
        await medicalServiceController.getMedicalServicesForAssignedMedic(medicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentSuggestionController = context.watch<UserAppointmentSuggestionController>();
    final medicalServiceController  = context.watch<MedicalServiceController>();

    if (appointmentSuggestionController.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (medicalServiceController.loadingServices) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (appointmentSuggestionController.error != null) {
      return Scaffold(
        body: Center(child: Text('Error loading suggestions: ${appointmentSuggestionController.error}')),
      );
    }

    if (medicalServiceController.error != null) {
      return Scaffold(
        body: Center(child: Text('Error loading services: ${medicalServiceController.error}')),
      );
    }

    final pending = appointmentSuggestionController.myAppointmentSuggestions
        .where((s) => s.status == 'pending')
        .toList();

    if (pending.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Suggestions'),
          backgroundColor: AppColors.primaryRed,
        ),
        body: const Center(
          child: Text(
            'No pending suggestions.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appointment Suggestions'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final s = pending[i];
          return SuggestionItem(
            apppointmentSuggestion: s,
            onRespond: (id, status) async {
              await appointmentSuggestionController.respondToSuggestion(id, status);
              if (status == 'accepted') {
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
    );
  }
}
