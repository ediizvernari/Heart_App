import 'package:frontend/features/user_health_data/data/api/user_health_data_api.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository.dart';

class UserHealthDataRepositoryImpl implements UserHealthDataRepository {
  @override
  Future<bool> checkUserHasHealthData() {
    return UserHealthDataApi.checkUserHasHealthData();
  }

  @override
  Future<UserHealthData> getUserHealthDataForPrediction() {
    return UserHealthDataApi.getUserHealthDataForPrediction();
  }

  @override
  Future<UserHealthData> upsertUserHealthData(UserHealthData dto) {
    return UserHealthDataApi.upsertUserHealthData(dto);
  }
}
