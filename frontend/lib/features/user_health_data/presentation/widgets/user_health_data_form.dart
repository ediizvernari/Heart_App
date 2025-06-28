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
      setState(() {
        _pickedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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
    final errorMessage = UserHealthDataValidator.validateUserHealthData(
      birthDate: _birthDateController.text,
      height: _heightController.text,
      weight: _weightController.text,
      systolicBP: _systolicBPController.text,
      diastolicBP: _diastolicBPController.text,
      cholesterolLevel: _cholesterolLevel,
    );
    if (errorMessage != null) {
      return _showError(errorMessage);
    }

    final userHealthDataDto = UserHealthData(
      dateOfBirth: _pickedDate!,
      heightCm: int.parse(_heightController.text),
      weightKg: int.parse(_weightController.text),
      systolicBloodPressure: int.parse(_systolicBPController.text),
      diastolicBloodPressure: int.parse(_diastolicBPController.text),
      cholesterolLevel: _cholesterolLevel!,
    );

    final userHealthDataController = context.read<UserHealthDataController>();
    await userHealthDataController.upsertUserHealthData(userHealthDataDto);

    if (userHealthDataController.error != null) {
      return _showError(userHealthDataController.error!);
    }
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final choice = await showDialog<_NextPage>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Health Data Saved!'),
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

    switch (choice) {
      case _NextPage.prediction:
        navigator.pushReplacementNamed('/prediction');
        break;
      case _NextPage.main:
      default:
        navigator.pushReplacementNamed('/user_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userHealthDataController = context.watch<UserHealthDataController>();

    if (userHealthDataController.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(userHealthDataController.error!);
        userHealthDataController.clearError();
      });
    }

    InputDecoration buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.cardBackground),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: AppColors.background.withAlpha(50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withAlpha(50),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.background.withAlpha(25),
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
                decoration: buildDecoration('Birth Date'),
                style: const TextStyle(color: AppColors.background),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration('Height (cm)'),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration('Weight (kg)'),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _systolicBPController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration('Systolic BP (mmHg)'),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _diastolicBPController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration('Diastolic BP (mmHg)'),
                style: const TextStyle(color: AppColors.background),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _cholesterolLevel,
                dropdownColor: AppColors.primaryBlue,
                decoration: buildDecoration('Cholesterol Level'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.background),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Normal')),
                  DropdownMenuItem(value: 2, child: Text('Above Normal')),
                  DropdownMenuItem(value: 3, child: Text('Way Above Normal')),
                ],
                onChanged: (v) => setState(() => _cholesterolLevel = v),
              ),
              const SizedBox(height: 32),

              userHealthDataController.isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                  : RoundedButton(
                      text: 'Submit',
                      onPressed: _submit,
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.background,
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