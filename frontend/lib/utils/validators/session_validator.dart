import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';

class SessionValidator {
  static Future<void> verifyToken(BuildContext context) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    if (token == null || JwtDecoder.isExpired(token)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
