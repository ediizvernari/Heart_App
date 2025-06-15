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
  late TextEditingController _medicalServiceNameController;
  late TextEditingController _medicalServicePriceController;
  late TextEditingController _medicalServiceDurationController;

  @override
  void initState() {
    super.initState();
    final svc = widget.service;
    _medicalServiceNameController = TextEditingController(text: svc?.name ?? '');
    _medicalServicePriceController = TextEditingController(text: svc != null ? svc.price.toString() : '');
    _medicalServiceDurationController = TextEditingController(text: svc != null ? svc.durationMinutes.toString() : '');

    final controller = context.read<MedicalServiceController>();
    if (controller.medicalServiceTypes.isEmpty) {
      controller.getAllMedicalServiceData();
    }
  }

  @override
  void dispose() {
    _medicalServiceNameController.dispose();
    _medicalServicePriceController.dispose();
    _medicalServiceDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicalServiceController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  widget.service == null ? 'New Service' : 'Edit Service',
                  style: AppTextStyles.dialogTitle.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medicalServiceNameController,
                  style: AppTextStyles.dialogContent.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: Colors.black54,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // 4) Price field
                TextFormField(
                  controller: _medicalServicePriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.dialogContent.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: Colors.black54,
                    ),
                    border: const OutlineInputBorder(),
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.dialogContent.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 5) Duration field
                TextFormField(
                  controller: _medicalServiceDurationController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.dialogContent.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Duration (min)',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: Colors.black54,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || int.tryParse(v.trim()) == null) {
                      return 'Enter a valid duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 6) Actions: Cancel & Create/Save
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        final name = _medicalServiceNameController.text.trim();
                        final price = double.parse(_medicalServicePriceController.text.trim());
                        final duration = int.parse(_medicalServiceDurationController.text.trim());

                        final newService = MedicalService(
                          id: widget.service?.id ?? 0,
                          medicId: widget.service?.medicId ?? 0,
                          medicalServiceTypeId: widget.service?.medicalServiceTypeId ?? 0,
                          name: name,
                          price: price.toInt(),
                          durationMinutes: duration,
                        );

                        if (widget.service == null) {
                          controller.createMedicalService(newService);
                        } else {
                          controller.updateMedicalService(newService);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        widget.service == null ? 'Create' : 'Save',
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
      ),
    );
  }
}
