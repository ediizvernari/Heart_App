import 'package:frontend/features/cvd_prediction/data/repositories/cvd_prediction_repository.dart';
import 'package:frontend/core/network/api_exception.dart';
import '../api/cvd_prediction_api.dart';
import '../models/prediction_result.dart';

class CvdPredictionRepositoryImpl implements CvdPredictionRepository {
  @override
  Future<PredictionResult> getCvdPredictionPercentage() {
    return CvdPredictionApi.getCvdPredictionPercentage()
      .onError((error, stack) {
        if (error is ApiException) throw error;
        throw ApiException(-1, error.toString());
      });
  }
}