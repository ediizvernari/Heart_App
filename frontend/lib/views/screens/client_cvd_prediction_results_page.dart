import 'package:flutter/material.dart';

class ClientCVDPredictionResultsPage extends StatelessWidget {
  final Map<String, dynamic> healthData;
  final double predictedProbability;

  //TODO: Apply the token verification here as well (Available for every page)
  const ClientCVDPredictionResultsPage({
    Key? key,
    required this.healthData,
    required this.predictedProbability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert probability to a readable percentage
    final String riskPercentage = predictedProbability.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CVD Prediction Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Your predicted probability of Cardiovascular Disease is $riskPercentage%",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              "Health Data Used:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: healthData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
