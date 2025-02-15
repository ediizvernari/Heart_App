import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/home_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter and FastAPI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AutoCheck(),
    );
  }
}

class AutoCheck extends StatelessWidget {
  const AutoCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getToken(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null && !isTokenExpired(snapshot.data!)) {
          return const HomePage();
        } else {
          return const HomePage();
        }
      },
    );
  }

  Future<String?> getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}