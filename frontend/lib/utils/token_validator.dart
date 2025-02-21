// auth_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/screens/home_page.dart'; // Import your login page

Future<void> verifyToken(BuildContext context) async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');

  print('Token: $token'); // Debugging line

  if (token == null) {
    print('Token is null'); // Debugging line
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else if (JwtDecoder.isExpired(token)) {
    print('Token is expired'); // Debugging line
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    print('Token is valid'); // Debugging line
  }
}
