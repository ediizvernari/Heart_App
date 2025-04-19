import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'home_screen.dart';
import '../client_main_page.dart';

class AutoCheck extends StatefulWidget {
  const AutoCheck({super.key});

  @override
  State<AutoCheck> createState() => _AutoCheckState();
}

class _AutoCheckState extends State<AutoCheck> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    String? token = await storage.read(key: 'auth_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      // Navigate to ClientMainPage if token is valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientMainPage()),
      );
    } else {
      // Navigate to HomePage if no valid token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator while checking
      ),
    );
  }
}
