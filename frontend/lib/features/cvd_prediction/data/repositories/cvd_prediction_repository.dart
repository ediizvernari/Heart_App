import 'package:frontend/features/cvd_prediction/data/models/prediction_result.dart';

abstract class CvdPredictionRepository {
  Future<PredictionResult> getCvdPredictionPercentage();
}