import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/models/medic_availability_model.dart';
import '../controllers/medic_availability_controller.dart';

class NewSlotDialog extends StatefulWidget {
  const NewSlotDialog({Key? key}) : super(key: key);

  @override
  _NewSlotDialogState createState() => _NewSlotDialogState();
}

class _NewSlotDialogState extends State<NewSlotDialog> {
  int? _weekday;
  TimeOfDay? _start, _end;
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final medicAvailabilityController = context.read<MedicAvailabilityController>();

    return AlertDialog(
      title: const Text('Add Availability Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Day of Week'),
            items: List.generate(
              7,
              (i) => DropdownMenuItem(value: i, child: Text(_labels[i])),
            ),
            onChanged: (v) => setState(() => _weekday = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Start:'),
              const Spacer(),
              Text(_start?.format(context) ?? '—'),
              TextButton(onPressed: () => _pickTime(isStart: true), child: const Text('Pick')),
            ],
          ),
          Row(
            children: [
              const Text('End:'),
              const Spacer(),
              Text(_end?.format(context) ?? '—'),
              TextButton(onPressed: () => _pickTime(isStart: false), child: const Text('Pick')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
          onPressed: (_weekday != null && _start != null && _end != null)
              ? () async {
                  Navigator.pop(context);
                  final slot = MedicAvailability(
                    id: 0,
                    weekday: _weekday!,
                    startTime: _format(_start!),
                    endTime: _format(_end!),
                  );
                  await medicAvailabilityController.addAvailability(slot);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  String _format(TimeOfDay t) {
    return t.hour.toString().padLeft(2, '0') +
        ':' +
        t.minute.toString().padLeft(2, '0');
  }
}
