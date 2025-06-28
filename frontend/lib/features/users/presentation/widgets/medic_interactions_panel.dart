import 'package:flutter/material.dart';
import 'package:frontend/widgets/action_card.dart';

class MedicInteractionsPanel extends StatelessWidget {
  final VoidCallback onSuggestions;
  final VoidCallback onUnassign;
  final VoidCallback onAppointments;

  const MedicInteractionsPanel({
    Key? key,
    required this.onSuggestions,
    required this.onUnassign,
    required this.onAppointments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.message,
                  label: 'My Suggestions',
                  onTap: onSuggestions,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: ActionCard(
                  icon: Icons.link_off,
                  label: 'Unassign Medic',
                  onTap: onUnassign,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ActionCard(
              icon: Icons.event_note,
              label: 'My Appointments',
              onTap: onAppointments,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }
}
