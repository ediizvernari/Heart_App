import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medical_service.dart';
import '../controllers/medical_service_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class MedicalServiceFormDialog extends StatefulWidget {
  final MedicalService? service;

  const MedicalServiceFormDialog({Key? key, this.service}) : super(key: key);

  @override
  _MedicalServiceFormDialogState createState() => _MedicalServiceFormDialogState();
}

class _MedicalServiceFormDialogState extends State<MedicalServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _typeId;
  late String _name;
  late int _price;
  late int _duration;

  @override
  void initState() {
    super.initState();
    final svc = widget.service;
    _typeId = svc?.medicalServiceTypeId ?? 0;
    _name = svc?.name ?? '';
    _price = svc?.price ?? 0;
    _duration = svc?.durationMinutes ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final ctl = context.read<MedicalServiceController>();
    final types = ctl.types;

    return AlertDialog(
      title: Text(
        widget.service == null ? 'New Service' : 'Edit Service',
        style: AppTextStyles.welcomeHeader,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _typeId > 0 ? _typeId : null,
                items: types
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            t.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: types.isEmpty
                    ? null
                    : (v) => setState(() => _typeId = v!),
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  hintText: types.isEmpty ? 'Loading types…' : null,
                ),
                validator: (v) => v == null || v == 0 ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => _name = v!.trim(),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: '$_price',
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _price = int.tryParse(v!) ?? 0,
              ),
              TextFormField(
                initialValue: '$_duration',
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _duration = int.tryParse(v!) ?? 0,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryRed),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            _formKey.currentState!.save();

            final newService = MedicalService(
              id: widget.service?.id ?? 0,
              medicId: 0, // backend will overwrite if needed
              medicalServiceTypeId: _typeId,
              name: _name,
              price: _price,
              durationMinutes: _duration,
            );

            if (widget.service == null) {
              ctl.createMedicalService(newService);
            } else {
              ctl.updateMedicalService(newService);
            }

            Navigator.pop(context);
          },
          child: Text(
            widget.service == null ? 'Create' : 'Save',
            style: AppTextStyles.buttonText.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
