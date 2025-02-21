import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/personal_data_validator.dart';
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

  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
    verifyToken(context);
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPersonalData() async {
    bool isValid = FormValidators.validatePersonalData(
      birthDate: birthDateController.text,
      height: heightController.text,
      weight: weightController.text,
      cigarettesPerDay: cigarettesController.text,
      cholesterol: cholesterolController.text,
      glucose: glucoseController.text,
      selectedSex: _selectedSex,
      selectedEducationLevel: _selectedEducationLevel,
      currentSmoker: _currentSmoker,
      bpmMed: _BPMeds,
      prevalentStroke: _prevalentStroke,
      prevalentHyp: _prevalentHyp,
      diabetes: _diabetes,
    );

    if (!isValid) {
      _showErrorPopup('Please fill out all fields correctly.');
      return;
    }

    final Map<String, dynamic> data = {
    "birth_date": birthDateController.text,
    "height": int.parse(heightController.text),
    "weight": int.parse(weightController.text),
    "is_male": _selectedSex == "Male" ? 1 : 0,  // Assuming is_male is 1 for Male and 0 for Female
    "education": _selectedEducationLevel,
    "current_smoker": _currentSmoker != null ? 1 : 0,  // Assuming current_smoker is 1 for true and 0 for false
    "cigs_per_day": int.parse(cigarettesController.text),
    "BPMeds": _BPMeds != null ? 1 : 0,  // Assuming BPMeds is 1 for true and 0 for false
    "prevalentStroke": _prevalentStroke != null ? 1 : 0,  // Assuming prevalence is boolean (1 for true)
    "prevalentHyp": _prevalentHyp != null ? 1 : 0,  // Same as above
    "diabetes": _diabetes != null ? 1 : 0,  // Same as above
    "totChol": int.parse(cholesterolController.text),
    "glucose": int.parse(glucoseController.text),
    };

    String? token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/personal_data/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );



    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClientMainPage()),
      );
    } else {
      print('Response body: ${response.body}');
      _showErrorPopup('An error occurred. Please try again.');
      }
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
                value: _currentSmoker,
                decoration: const InputDecoration(
                  labelText: 'Current Smoker',
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
                    _currentSmoker = newValue;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                value: _BPMeds,
                decoration: const InputDecoration(
                  labelText: 'Currently on BP Meds',
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
                  labelText: 'Prevalent Stroke',
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
                  labelText: 'Prevalent Hypertension',
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
                  labelText: 'Diabetes',
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
