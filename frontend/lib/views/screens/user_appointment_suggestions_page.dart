import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_appointment_suggestion_controller.dart';
import '../../controllers/medical_service_controller.dart';
import '../../widgets/appointment_suggestion_item.dart';
import '../../constants/app_colors.dart';


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
      final suggCtl = context.read<UserAppointmentSuggestionController>();
      final svcCtl  = context.read<MedicalServiceController>();

      // 1) load the user's suggestions
      await suggCtl.loadMySuggestions();

      // 2) load services for each medic who made a suggestion
      final medics = suggCtl.mySuggestions.map((s) => s.medicId).toSet();
      for (final medicId in medics) {
        await svcCtl.fetchServicesForAssignedMedic(medicId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggCtl = context.watch<UserAppointmentSuggestionController>();
    final svcCtl  = context.watch<MedicalServiceController>();

    // 1) suggestions still loading?
    if (suggCtl.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) services still loading?
    if (svcCtl.loadingServices) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) any errors?
    if (suggCtl.error != null) {
      return Scaffold(
        body: Center(child: Text('Error loading suggestions: ${suggCtl.error}')),
      );
    }
    if (svcCtl.error != null) {
      return Scaffold(
        body: Center(child: Text('Error loading services: ${svcCtl.error}')),
      );
    }

    // now both are in
    final pending = suggCtl.mySuggestions
        .where((s) => s.status == 'pending')
        .toList();

    // if there are no pending suggestions, still show the same Scaffold with AppBar
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
            suggestion: s,
            onRespond: (id, status) async {
              await suggCtl.respondToSuggestion(id, status);
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
