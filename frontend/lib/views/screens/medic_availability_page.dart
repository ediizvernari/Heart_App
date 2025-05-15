import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/medic_availability_controller.dart';
import '../../models/medic_availability.dart';
import '../../constants/app_colors.dart';

class MedicAvailabilityPage extends StatefulWidget {
  const MedicAvailabilityPage({Key? key}) : super(key: key);

  @override
  _MedicAvailabilityPageState createState() =>
      _MedicAvailabilityPageState();
}

class _MedicAvailabilityPageState
    extends State<MedicAvailabilityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicAvailabilityController>().loadMyAvailabilities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctl = context.watch<MedicAvailabilityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: _buildBody(ctl),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
        onPressed: () {
          final parentCtl = context.read<MedicAvailabilityController>();
          showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: parentCtl,
              child: const _NewSlotDialog(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(MedicAvailabilityController ctl) {
    if (ctl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctl.errorMessage != null) {
      return Center(
        child: Text(
          'Error: ${ctl.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (ctl.slots.isEmpty) {
      return const Center(child: Text('No availability slots yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctl.slots.length,
      itemBuilder: (ctx, i) {
        final slot = ctl.slots[i];
        final dayName = _weekdayName(slot.weekday);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text('$dayName • ${slot.startTime}–${slot.endTime}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(ctx, slot.id),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext ctx, int slotId) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete this slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<MedicAvailabilityController>()
                 .removeAvailability(slotId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return w >= 0 && w < names.length ? names[w] : 'Day';
  }
}

class _NewSlotDialog extends StatefulWidget {
  const _NewSlotDialog({Key? key}) : super(key: key);
  @override
  _NewSlotDialogState createState() => _NewSlotDialogState();
}

class _NewSlotDialogState extends State<_NewSlotDialog> {
  int? _weekday;
  TimeOfDay? _start, _end;
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final ctl = context.read<MedicAvailabilityController>();
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
              TextButton(onPressed: () => _pickTime(true), child: const Text('Pick')),
            ],
          ),
          Row(
            children: [
              const Text('End:'),
              const Spacer(),
              Text(_end?.format(context) ?? '—'),
              TextButton(onPressed: () => _pickTime(false), child: const Text('Pick')),
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
                  await ctl.addAvailability(slot);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _start = picked;
        else _end = picked;
      });
    }
  }

  String _format(TimeOfDay t) =>
      t.hour.toString().padLeft(2, '0') +
      ':' +
      t.minute.toString().padLeft(2, '0');
}