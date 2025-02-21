import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/screens/home_page.dart';

Future<void> verifyToken(BuildContext context) async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');


  if (token == null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else if (JwtDecoder.isExpired(token)) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}
