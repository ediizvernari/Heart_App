/*import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/client_main_page.dart';
import 'package:frontend/screens/client_personal_data_insertion_page.dart';
import 'package:http/http.dart' as http;

Future<void> checkUserHealthData(BuildContext context, String token) async {
  
  final response = await http.get(
    Uri.parse('https://10.0.2.2:8000/users/user_has_health_data'),
    headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      }
  );

  if (response.statusCode == 200) {
    final bool userHasHealthData = response.body == 'true';
    if (userHasHealthData) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClientCardiovascularPredictionPage()),
      );
    } else {
      
    })
  }
  
}*/