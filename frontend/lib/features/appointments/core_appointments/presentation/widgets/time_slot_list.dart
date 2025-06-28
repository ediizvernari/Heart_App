import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/features/appointments/scheduling/data/models/time_slot_model.dart';


class TimeSlotList extends StatelessWidget {
  final List<TimeSlot> freeSlots;
  final bool isLoading;
  final ValueChanged<TimeSlot> onSlotTap;

  const TimeSlotList({
    Key? key,
    required this.freeSlots,
    required this.isLoading,
    required this.onSlotTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
        ),
      );
    }

    if (freeSlots.isEmpty) {
      return const Text(
        'No available slots',
        style: TextStyle(color: AppColors.textPrimary),
        textAlign: TextAlign.center,
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: freeSlots.length,
        separatorBuilder: (_, __) =>
            const Divider(color: Colors.white24),
        itemBuilder: (_, i) {
          final slot = freeSlots[i];
          final startTime = slot.startDateTime;
          final label = DateFormat.jm().format(startTime);

          return ListTile(
            title: Text(
              label,
              style: const TextStyle(color: Colors.black87),
            ),
            subtitle: Text(
              '${slot.start} – ${slot.end}',
              style: AppTextStyles.buttonText.copyWith(
                color: Colors.black54,
              ),
            ),
            onTap: () => onSlotTap(slot),
          );
        },
      ),
    );
  }
}
