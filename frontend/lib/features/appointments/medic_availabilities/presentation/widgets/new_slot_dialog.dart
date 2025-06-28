import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

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

  bool get _isValidInterval {
    if (_start == null || _end == null) return false;
    final startMinutes = _start!.hour * 60 + _start!.minute;
    final endMinutes = _end!.hour * 60 + _end!.minute;
    return endMinutes > startMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final medicAvailabilityController = context.read<MedicAvailabilityController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Availability Slot',
                style: AppTextStyles.dialogTitle,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _weekday,
                decoration: InputDecoration(
                  labelText: 'Day of Week',
                  labelStyle: AppTextStyles.subtitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                  hintText: _weekday == null ? 'Select a day' : null,
                  hintStyle: AppTextStyles.body
                ),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      _labels[i],
                      style: AppTextStyles.body
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _weekday = v),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text('Start:', style: AppTextStyles.dialogContent),
                  const Spacer(),
                  Text(
                    _start?.format(context) ?? '—',
                    style: AppTextStyles.dialogContent
                  ),
                  TextButton(
                    onPressed: () => _pickTime(isStart: true),
                    child: const Text(
                      'Pick',
                      style: AppTextStyles.blueButtonText
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  const Text('End:', style: AppTextStyles.dialogContent),
                  const Spacer(),
                  Text(
                    _end?.format(context) ?? '—',
                    style: AppTextStyles.dialogContent
                  ),
                  TextButton(
                    onPressed: () => _pickTime(isStart: false),
                    child: const Text(
                      'Pick',
                      style: AppTextStyles.blueButtonText
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_start != null && _end != null && !_isValidInterval) ...[
                const Text(
                  'End time must be after start time',
                  style: TextStyle(color: AppColors.errorRed),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: AppTextStyles.blackDialogButton
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: (_weekday != null && _start != null && _end != null && _isValidInterval)
                        ? () async {
                            Navigator.pop(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final slot = MedicAvailability(
                              id: 0,
                              weekday: _weekday!,
                              startTime: _format(_start!),
                              endTime: _format(_end!),
                            );
                            try {
                              await medicAvailabilityController.addAvailability(slot);
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        : null,
                    child: const Text(
                      'Save',
                      style: AppTextStyles.buttonText
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _start = pickedTime;
        } else {
          _end = pickedTime;
        }
      });
    }
  }

  String _format(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
