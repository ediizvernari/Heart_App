import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
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
    final medicAvailabilityController =
        context.read<MedicAvailabilityController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Availability Slot',
                style: AppTextStyles.dialogTitle.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _weekday,
                decoration: InputDecoration(
                  labelText: 'Day of Week',
                  labelStyle: AppTextStyles.subheader.copyWith(
                    color: Colors.black54,
                  ),
                  border: const OutlineInputBorder(),
                  hintText: _weekday == null ? 'Select a day' : null,
                  hintStyle: AppTextStyles.dialogContent.copyWith(
                    color: Colors.black38,
                  ),
                ),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      _labels[i],
                      style: AppTextStyles.dialogContent.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _weekday = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Text('Start:', style: AppTextStyles.dialogContent),
                  const Spacer(),
                  Text(
                    _start?.format(context) ?? '—',
                    style: AppTextStyles.dialogContent.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickTime(isStart: true),
                    child: Text(
                      'Pick',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text('End:', style: AppTextStyles.dialogContent),
                  const Spacer(),
                  Text(
                    _end?.format(context) ?? '—',
                    style: AppTextStyles.dialogContent.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickTime(isStart: false),
                    child: Text(
                      'Pick',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.dialogButton.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
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
                    child: Text(
                      'Save',
                      style: AppTextStyles.buttonText.copyWith(
                        color: Colors.white,
                      ),
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
