import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../../data/models/medic_availability_model.dart';

class AvailabilityItem extends StatelessWidget {
  final MedicAvailability slot;
  final VoidCallback onDelete;

  const AvailabilityItem({
    Key? key,
    required this.slot,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayName = _weekdayName(slot.weekday);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text('$dayName • ${slot.startTime}–${slot.endTime}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.primaryRed),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _weekdayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (w >= 0 && w < names.length) ? names[w] : 'Day';
  }
}
