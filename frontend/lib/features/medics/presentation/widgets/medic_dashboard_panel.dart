import 'package:flutter/material.dart';
import 'package:frontend/widgets/action_card.dart';

class MedicDashboardPanel extends StatelessWidget {
  const MedicDashboardPanel({
    Key? key,
    required this.onAssignedUsers,
    required this.onMedicalServices,
    required this.onAppointments,
    required this.onAvailability,
  }) : super(key: key);

  final VoidCallback onAssignedUsers;
  final VoidCallback onMedicalServices;
  final VoidCallback onAppointments;
  final VoidCallback onAvailability;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ActionCard(
                    icon: Icons.people, 
                    label: 'My Assigned Users',
                    onTap: onAssignedUsers,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ActionCard(
                    icon: Icons.medical_services,
                    label: 'My Medical Services',
                    onTap: onMedicalServices,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ActionCard(
                    icon: Icons.calendar_today,
                    label: 'My Appointments',
                    onTap: onAppointments,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ActionCard(
                    icon: Icons.access_time,
                    label: 'My Time Availability',
                    onTap: onAvailability,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
