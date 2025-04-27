import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/validators/user_health_data_validator.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/validators/session_validator.dart';
import 'package:frontend/views/screens/client_main_page.dart';

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
  final TextEditingController systolicBPController = TextEditingController();
  final TextEditingController diastolicBPController = TextEditingController();

  int? _cholesterolLevel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionValidator.verifyToken(context);
    });
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
    bool isValid = UserHealthDataValidator.validateUserHealthData(
      birthDate: birthDateController.text,
      height: heightController.text,
      weight: weightController.text,
      systolicBP: systolicBPController.text,
      diastolicBP: diastolicBPController.text,
      cholesterolLevel: _cholesterolLevel,
    );

    if (!isValid) {
      _showErrorPopup('Please fill out all fields correctly.');
      return;
    }

    final Map<String, dynamic> data = {
      "birth_date": birthDateController.text,
      "height": int.parse(heightController.text),
      "weight": int.parse(weightController.text),
      "ap_hi": int.parse(systolicBPController.text),
      "ap_lo": int.parse(diastolicBPController.text),
      "cholesterol_level": _cholesterolLevel,
    };

    String? token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('https://10.0.2.2:8000/user_health_data/create_or_update_user_health_data'),
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
                controller: systolicBPController,
                decoration: const InputDecoration(labelText: 'Systolic BP (mmHg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diastolicBPController,
                decoration: const InputDecoration(labelText: 'Diastolic BP (mmHg)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<int>(
                value: _cholesterolLevel,
                decoration: const InputDecoration(
                  labelText: 'Cholesterol Level',
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
                onChanged: (int? newValue) {
                  setState(() {
                    _cholesterolLevel = newValue;
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
