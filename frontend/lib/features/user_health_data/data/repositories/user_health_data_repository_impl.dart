import 'package:frontend/features/user_health_data/data/api/user_health_data_api.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';

class UserHealthDataRepositoryImpl implements UserHealthDataRepository {
  @override
  Future<bool> checkUserHasHealthData() async {
    final token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserHealthDataApi.checkUserHasHealthData(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserHealthData> getUserHealthDataForPrediction() async {
    final token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserHealthDataApi.getUserHealthDataForPrediction(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<UserHealthData> upsertUserHealthData(UserHealthData dto) async {
    final token = await AuthStore.getToken();
    if (token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await UserHealthDataApi.upsertUserHealthData(token, dto);
    } on ApiException {
      rethrow;
    }
  }
}