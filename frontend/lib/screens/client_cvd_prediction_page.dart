import 'package:flutter/material.dart';

class ClientCVDPredictionPage extends StatelessWidget {
  const ClientCVDPredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CVD Prediction"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Add prediction logic here
          },
          child: const Text("Get Prediction"),
        ),
      ),
    );
  }
}
