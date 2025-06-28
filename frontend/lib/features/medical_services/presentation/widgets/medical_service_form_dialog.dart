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
  int? _selectedTypeId;
  late TextEditingController _medicalServiceNameController;
  late TextEditingController _medicalServicePriceController;
  late TextEditingController _medicalServiceDurationController;

  @override
  void initState() {
    super.initState();
    final medicalService = widget.service;
    _selectedTypeId = medicalService?.medicalServiceTypeId;
    _medicalServiceNameController = TextEditingController(text: medicalService?.name ?? '');
    _medicalServicePriceController = TextEditingController(text: medicalService != null ? medicalService.price.toString() : '');
    _medicalServiceDurationController = TextEditingController(text: medicalService != null ? medicalService.durationMinutes.toString() : '');

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
    final types = controller.medicalServiceTypes;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
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
                  style: AppTextStyles.dialogTitle,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: _selectedTypeId,
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    hintText: types.isEmpty ? 'Loading types…' : null,
                    hintStyle: AppTextStyles.dialogContent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  items: types
                      .map((t) => DropdownMenuItem<int>(
                            value: t.id,
                            child: Text(
                              t.name,
                              style: AppTextStyles.dialogContent.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged:
                      types.isEmpty ? null : (v) => setState(() => _selectedTypeId = v),
                  validator: (v) =>
                      v == null ? 'Please select a type' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medicalServiceNameController,
                  style: AppTextStyles.dialogContent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medicalServicePriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.dialogContent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    prefixText: '\$ ',
                    prefixStyle: AppTextStyles.dialogContent.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || int.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medicalServiceDurationController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.dialogContent.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Duration (min)',
                    labelStyle: AppTextStyles.subheader.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || int.tryParse(v.trim()) == null) {
                      return 'Enter a valid duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.dialogButton.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        final name = _medicalServiceNameController.text.trim();
                        final price = double.parse(_medicalServicePriceController.text.trim());
                        final duration = int.parse(_medicalServiceDurationController.text.trim());
                        final typeId = _selectedTypeId!;

                        final newService = MedicalService(
                          id: widget.service?.id ?? 0,
                          medicId: widget.service?.medicId ?? 0,
                          medicalServiceTypeId: typeId,
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
                        style: AppTextStyles.buttonText
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
