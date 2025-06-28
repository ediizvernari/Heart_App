import '../models/prediction_result.dart';

abstract class CvdPredictionRepository {
  Future<PredictionResult> getCvdPredictionPercentage();
}