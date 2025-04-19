import '../services/user_health_data_service.dart';
import '../services/prediction_service.dart';

class ClientCVDController {
  Future<Map<String, dynamic>?> getUserHealthDataForPrediction(String token) async {
    final hasData = await UserHealthDataService.checkUserHasHealthData(token);
    if (!hasData) return null;

    return await UserHealthDataService.fetchUserHealthDataForPrediction(token);
  }

  Future<double> getPredictedCVDProbability(String token) async {
    return await PredictionService.getCVDPredictionPercentage(token);
  }
}
