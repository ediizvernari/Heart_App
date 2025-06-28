import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '$dayName • ${slot.startTime}–${slot.endTime}',
                style: AppTextStyles.subtitle
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppColors.primaryBlue,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (w >= 0 && w < names.length) ? names[w] : 'Day';
  }
}
