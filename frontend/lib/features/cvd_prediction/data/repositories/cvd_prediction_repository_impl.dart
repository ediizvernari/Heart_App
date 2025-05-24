import 'package:frontend/features/cvd_prediction/data/api/cvd_prediction_api.dart';
import 'package:frontend/features/cvd_prediction/data/models/prediction_result.dart';
import 'package:frontend/features/cvd_prediction/data/repositories/cvd_prediction_repository.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';

class CvdPredictionRepositoryImpl implements CvdPredictionRepository {
  @override
  Future<PredictionResult> getCvdPredictionPercentage() async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    return await CvdPredictionApi.getCVDPredictionPercentage(token);
  }
}