import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/views/screens/medic_main_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'home_screen.dart';
import '../user_main_page.dart';

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
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String role = decodedToken['role'];

    if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientMainPage()),
      );
    } else if (role == 'medic') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MedicMainPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  } else {
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
