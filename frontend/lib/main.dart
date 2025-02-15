import 'package:flutter/material.dart';
import 'utils/auto_check.dart';


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
