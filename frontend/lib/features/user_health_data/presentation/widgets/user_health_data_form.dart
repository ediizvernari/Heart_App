import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/rounded_button.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators/user_health_data_validator.dart';
import 'package:frontend/features/user_health_data/presentation/controllers/user_health_data_controller.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';

enum _NextPage { main, prediction }

class UserHealthDataForm extends StatefulWidget {
  const UserHealthDataForm({super.key});

  @override
  State<UserHealthDataForm> createState() => _UserHealthDataFormState();
}

class _UserHealthDataFormState extends State<UserHealthDataForm> {
  final _birthDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  int? _cholesterolLevel;
  DateTime? _pickedDate;

  @override
  void dispose() {
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _pickedDate = picked;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final valid = UserHealthDataValidator.validateUserHealthData(
      birthDate: _birthDateController.text,
      height: _heightController.text,
      weight: _weightController.text,
      systolicBP: _systolicBPController.text,
      diastolicBP: _diastolicBPController.text,
      cholesterolLevel: _cholesterolLevel,
    );
    if (!valid) {
      return _showError('Please fill out all fields correctly.');
    }

    final dto = UserHealthData(
      dateOfBirth: _pickedDate!,
      heightCm: int.parse(_heightController.text),
      weightKg: int.parse(_weightController.text),
      systolicBloodPressure: int.parse(_systolicBPController.text),
      diastolicBloodPressure: int.parse(_diastolicBPController.text),
      cholesterolLevel: _cholesterolLevel!,
    );

    final userHealthDataController = context.read<UserHealthDataController>();
    await userHealthDataController.upsertUserHealthData(dto);

    if (userHealthDataController.error != null) {
      return _showError(userHealthDataController.error!);
    }
    if (!mounted) return;
    final choice = await showDialog<_NextPage>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Data Saved'),
        content: const Text('Where would you like to go now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _NextPage.main),
            child: const Text('Main Page'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _NextPage.prediction),
            child: const Text('View My Prediction Results'),
          ),
        ],
      ),
    );

    // Navigate based on their choice
    switch (choice) {
      case _NextPage.prediction:
        Navigator.pushReplacementNamed(context, '/prediction');
        break;
      case _NextPage.main:
      default:
        Navigator.pushReplacementNamed(context, '/user_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UserHealthDataController>();

    if (ctrl.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(ctrl.error!);
        ctrl.clearError();
      });
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _birthDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Birth Date',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: Colors.black87),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Height (cm)',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Weight (kg)',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _systolicBPController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Systolic BP (mmHg)',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _diastolicBPController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Diastolic BP (mmHg)',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _cholesterolLevel,
                dropdownColor: AppColors.cardBackground,

                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black87),

                decoration: const InputDecoration(
                  labelText: 'Cholesterol Level',
                  labelStyle: TextStyle(color: Colors.white70),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Normal'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Above Normal'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Way Above Normal'),
                  ),
                ],
                onChanged: (v) => setState(() => _cholesterolLevel = v),
              ),
              const SizedBox(height: 32),

              ctrl.isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                  : RoundedButton(
                      text: 'Submit',
                      onPressed: _submit,
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      borderRadius: 30,
                      elevation: 8,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}