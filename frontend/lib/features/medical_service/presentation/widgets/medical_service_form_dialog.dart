import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/medical_service.dart';
import '../controllers/medical_service_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MedicalServiceFormDialog extends StatefulWidget {
  final MedicalService? service;

  const MedicalServiceFormDialog({Key? key, this.service}) : super(key: key);

  @override
  _MedicalServiceFormDialogState createState() => _MedicalServiceFormDialogState();
}

class _MedicalServiceFormDialogState extends State<MedicalServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _medicalServiceTypeId;
  late String _medicalServiceName;
  late int _medicalServicePrice;
  late int _medicalServiceDuration;

  @override
  void initState() {
    super.initState();
    final medicalService = widget.service;
    _medicalServiceTypeId = medicalService?.medicalServiceTypeId ?? 0;
    _medicalServiceName = medicalService?.name ?? '';
    _medicalServicePrice = medicalService?.price ?? 0;
    _medicalServiceDuration = medicalService?.durationMinutes ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final medicalServiceController = context.read<MedicalServiceController>();
    final types = medicalServiceController.medicalServiceTypes;

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
                value: _medicalServiceTypeId > 0 ? _medicalServiceTypeId : null,
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
                    : (v) => setState(() => _medicalServiceTypeId = v!),
                decoration: InputDecoration(
                  labelText: 'Service Type',
                  hintText: types.isEmpty ? 'Loading types…' : null,
                ),
                validator: (v) => v == null || v == 0 ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _medicalServiceName,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (v) => _medicalServiceName = v!.trim(),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: '$_medicalServicePrice',
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _medicalServicePrice = int.tryParse(v!) ?? 0,
              ),
              TextFormField(
                initialValue: '$_medicalServiceDuration',
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _medicalServiceDuration = int.tryParse(v!) ?? 0,
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
              medicalServiceTypeId: _medicalServiceTypeId,
              name: _medicalServiceName,
              price: _medicalServicePrice,
              durationMinutes: _medicalServiceDuration,
            );

            if (widget.service == null) {
              medicalServiceController.createMedicalService(newService);
            } else {
              medicalServiceController.updateMedicalService(newService);
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
