import 'package:flutter/material.dart';
import 'utils/auto_check.dart';
import 'dart:io';

//TODO: Not the place for this todo to be here but handle the back button
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
