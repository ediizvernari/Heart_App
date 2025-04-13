import 'package:flutter/material.dart';

class MedicMainPage extends StatelessWidget {
  const MedicMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medic Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Hello, Medic!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
