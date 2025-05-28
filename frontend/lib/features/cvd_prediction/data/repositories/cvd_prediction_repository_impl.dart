import 'package:frontend/features/auth/data/auth_exception.dart';
import 'package:frontend/features/cvd_prediction/data/api/cvd_prediction_api.dart';
import 'package:frontend/features/cvd_prediction/data/models/prediction_result.dart';
import 'package:frontend/features/cvd_prediction/data/repositories/cvd_prediction_repository.dart';
import 'package:frontend/services/api_exception.dart';

class CvdPredictionRepositoryImpl implements CvdPredictionRepository {
  @override
  Future<PredictionResult> getCvdPredictionPercentage() async {
    try {
      return await CvdPredictionApi.getCvdPredictionPercentage();
    } on ApiException catch (e) {
      throw AuthException.networkError(e.message);
    } catch (e) {
      throw AuthException.networkError(e.toString());
    }
  }
}