class PredictionResult {
  final double prediction;

  PredictionResult({ required this.prediction });

  factory PredictionResult.fromJson(Map<String, dynamic> json) => PredictionResult(
        prediction: (json['prediction'] as num).toDouble(),
      );
}