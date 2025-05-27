import 'package:flutter/material.dart';
import 'package:frontend/utils/validators/user_health_data_validator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/custom_app_bar.dart';       // ← use same header
import 'package:frontend/widgets/rounded_button.dart';
import '../../data/models/user_health_data_model.dart';
import '../../presentation/controllers/user_health_data_controller.dart';

class ClientPersonalDataInsertionPage extends StatefulWidget {
  const ClientPersonalDataInsertionPage({super.key});

  @override
  ClientPersonalDataInsertionPageState createState() =>
      ClientPersonalDataInsertionPageState();
}

class ClientPersonalDataInsertionPageState
    extends State<ClientPersonalDataInsertionPage> {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _systolicBPController = TextEditingController();
  final TextEditingController _diastolicBPController = TextEditingController();
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

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitUserHealthData() async {
    bool isValid = UserHealthDataValidator.validateUserHealthData(
      birthDate: _birthDateController.text,
      height: _heightController.text,
      weight: _weightController.text,
      systolicBP: _systolicBPController.text,
      diastolicBP: _diastolicBPController.text,
      cholesterolLevel: _cholesterolLevel,
    );

    if (!isValid) {
      _showErrorPopup('Please fill out all fields correctly.');
      return;
    }

    final userHealthDataDto = UserHealthData(
      dateOfBirth: _pickedDate!,
      heightCm: int.parse(_heightController.text),
      weightKg: int.parse(_weightController.text),
      systolicBloodPressure: int.parse(_systolicBPController.text),
      diastolicBloodPressure: int.parse(_diastolicBPController.text),
      cholesterolLevel: _cholesterolLevel!,
    );

    final userHealthDataController =
        context.read<UserHealthDataController>();
    await userHealthDataController.upsertUserHealthData(userHealthDataDto);

    if (userHealthDataController.error != null) {
      _showErrorPopup(userHealthDataController.error!);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/prediction');
  }

  @override
  Widget build(BuildContext context) {
    final healthCtrl = context.watch<UserHealthDataController>();

    if (healthCtrl.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorPopup(healthCtrl.error!);
        healthCtrl.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryRed,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomAppBar(
          title: 'Enter Health Data',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.whiteOverlay,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Birth Date
                    TextField(
                      controller: _birthDateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Birth Date',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _pickedDate = picked;
                          _birthDateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Height
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),  
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Systolic BP
                    TextField(
                      controller: _systolicBPController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Systolic BP (mmHg)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Diastolic BP
                    TextField(
                      controller: _diastolicBPController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Diastolic BP (mmHg)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cholesterol
                    DropdownButtonFormField<int>(
                      value: _cholesterolLevel,
                      dropdownColor: AppColors.primaryRed,
                      decoration: const InputDecoration(
                        labelText: 'Cholesterol Level',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: AppColors.primaryRed),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Normal', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 2, child: Text('Above Normal', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(
                            value: 3, child: Text('Way Above Normal', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (v) => setState(() => _cholesterolLevel = v),
                    ),
                    const SizedBox(height: 24),

                    healthCtrl.isLoading
                        ? const CircularProgressIndicator()
                        : RoundedButton(
                            text: 'Submit Health Data',
                            onPressed: _submitUserHealthData,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}