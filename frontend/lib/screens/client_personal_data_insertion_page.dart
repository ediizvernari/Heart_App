import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/token_validator.dart';
import 'package:frontend/screens/client_main_page.dart';

class ClientPersonalDataInsertionPage extends StatefulWidget {
  const ClientPersonalDataInsertionPage({super.key});

  @override
  ClientPersonalDataInsertionPageState createState() =>
      ClientPersonalDataInsertionPageState();
}

class ClientPersonalDataInsertionPageState
    extends State<ClientPersonalDataInsertionPage> {
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController cigarettesController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  int? _selectedSex;
  int? _selectedEducationLevel;
  int? _currentSmoker;
  int? _BPMeds;
  int? _prevalentStroke;
  int? _prevalentHyp;
  int? _diabetes;

  @override
  void initState() {
    super.initState();
    verifyToken(context); // Token verification at the start
  }

  bool _isValidInteger(String value) {
    final intValue = int.tryParse(value);
    return intValue != null && intValue >= 0; // Valid non-negative integer
  }

  bool _isFieldEmpty(String value) {
    return value.isEmpty;
  }

  Future<void> _submitPersonalData() async {
    // Validate input fields
    if (_isFieldEmpty(birthDateController.text) ||
        _isFieldEmpty(heightController.text) ||
        _isFieldEmpty(weightController.text) ||
        _isFieldEmpty(cigarettesController.text) ||
        _isFieldEmpty(cholesterolController.text) ||
        _isFieldEmpty(glucoseController.text)) {
      _showErrorPopup('All fields must be filled out.');
      return;
    }

    if (!_isValidInteger(heightController.text)) {
      _showErrorPopup('Height must be a valid non-negative integer.');
      return;
    }

    if (!_isValidInteger(weightController.text)) {
      _showErrorPopup('Weight must be a valid non-negative integer.');
      return;
    }

    if (!_isValidInteger(cigarettesController.text)) {
      _showErrorPopup('Cigarettes per day must be a valid non-negative integer.');
      return;
    }

    if (!_isValidInteger(cholesterolController.text)) {
      _showErrorPopup('Cholesterol must be a valid non-negative integer.');
      return;
    }

    if (!_isValidInteger(glucoseController.text)) {
      _showErrorPopup('Glucose must be a valid non-negative integer.');
      return;
    }

    // Prepare the data to be sent to the backend
    final Map<String, dynamic> data = {
      "birthDate": birthDateController.text, // Store the birth date as a string
      "height": int.parse(heightController.text), // Convert to integer
      "weight": int.parse(weightController.text), // Convert to integer
      "sex": _selectedSex,
      "educationLevel": _selectedEducationLevel,
      "currentSmoker": _currentSmoker,
      "BPMeds": _BPMeds,
      "prevalentStroke": _prevalentStroke,
      "prevalentHyp": _prevalentHyp,
      "diabetes": _diabetes,
      "cigarettesPerDay": int.parse(cigarettesController.text), // Integer value
      "cholesterol": int.parse(cholesterolController.text), // Integer value (mg/dl)
      "glucose": int.parse(glucoseController.text), // Integer value (mg/dl)
    };

    // Send the data to the backend here...
    // You would call an API or some other service to submit the data
  }

  // Show a pop-up error message
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop-up
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert Personal Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: birthDateController,
                decoration: const InputDecoration(labelText: 'Birth Date'),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    birthDateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cigarettesController,
                decoration: const InputDecoration(labelText: 'Cigarettes per day'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cholesterolController,
                decoration: const InputDecoration(labelText: 'Cholesterol (mg/dl)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: glucoseController,
                decoration: const InputDecoration(labelText: 'Glucose (mg/dl)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<int>(
                value: _selectedSex,
                decoration: const InputDecoration(
                  labelText: 'Select Sex',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Female'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedEducationLevel,
                decoration: const InputDecoration(
                  labelText: 'Select Education Level',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Less than high school education'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('High school diploma or equivalent'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Some college or vocational training'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('College degree or higher'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedEducationLevel = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _BPMeds,
                decoration: const InputDecoration(
                  labelText: 'Do you take blood pressure medications?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _BPMeds = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _prevalentStroke,
                decoration: const InputDecoration(
                  labelText: 'Do you have prevalent stroke issues?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _prevalentStroke = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _prevalentHyp,
                decoration: const InputDecoration(
                  labelText: 'Do you have prevalent hypertension?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _prevalentHyp = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _diabetes,
                decoration: const InputDecoration(
                  labelText: 'Do you have diabetes?',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Yes'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No'),
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _diabetes = newValue;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _submitPersonalData,
                child: const Text('Submit Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
