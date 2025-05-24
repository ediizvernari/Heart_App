import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';

abstract class UserHealthDataRepository {
  Future<bool> checkUserHasHealthData();
  Future<UserHealthData> upsertUserHealthData(UserHealthData dto);
  Future<UserHealthData> getUserHealthDataForPrediction();
}