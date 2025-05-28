import 'package:frontend/features/user_health_data/data/api/user_health_data_api.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository.dart';
import 'package:frontend/services/api_exception.dart';

class UserHealthDataRepositoryImpl implements UserHealthDataRepository {
  @override
  Future<bool> checkUserHasHealthData() async {
    try {
      return await UserHealthDataApi.checkUserHasHealthData();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserHealthData> getUserHealthDataForPrediction() async {
    try {
      return await UserHealthDataApi.getUserHealthDataForPrediction();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserHealthData> upsertUserHealthData(UserHealthData dto) async {
    try {
      return await UserHealthDataApi.upsertUserHealthData(dto);
    } on ApiException {
      rethrow;
    }
  }
}