import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'login_page.dart'; // Import your login page

class ClientPersonalDataInsertionPage extends StatefulWidget {
  const ClientPersonalDataInsertionPage({super.key});

  @override
  ClientPersonalDataInsertionPageState createState() => ClientPersonalDataInsertionPageState();
}

class ClientPersonalDataInsertionPageState extends State<ClientPersonalDataInsertionPage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  int? _selectedSex;
  int? _selectedEducationLevel;
  int? _currentSmoker;
  // ignore: non_constant_identifier_names
  int? _BPMeds;
  int? _prevalentStroke;
  int? _prevalentHyp;
  int? _diabetes;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  Future<void> _verifyToken() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    print('Token: $token'); // Debugging line

    if (token == null) {
      print('Token is null'); // Debugging line
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>  LoginPage()),
      );
    } else if (JwtDecoder.isExpired(token)) {
      print('Token is expired'); // Debugging line
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>  LoginPage()),
      );
    } else {
      print('Token is valid'); // Debugging line
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
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<int>(
                value: _selectedSex,
                hint: const Text('Select Sex'),
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
              DropdownButton<int>(
                value: _selectedEducationLevel,
                hint: const Text('Select Education Level'),
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
              DropdownButton<int>(
                value: _currentSmoker,
                hint: const Text('Are you a current smoker?'),
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
              DropdownButton<int>(
                value: _BPMeds,
                hint: const Text('Are you on BP Meds?'),
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
              DropdownButton<int>(
                value: _prevalentStroke,
                hint: const Text('Have you had a prevalent stroke?'),
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
              DropdownButton<int>(
                value: _prevalentHyp,
                hint: const Text('Do you have prevalent hypertension?'),
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
              DropdownButton<int>(
                value: _diabetes,
                hint: const Text('Do you have diabetes?'),
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
            ],
          ),
        ),
      ),
    );
  }
}
