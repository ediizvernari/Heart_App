import 'package:flutter/material.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository.dart';
import 'package:frontend/core/network/api_exception.dart';

class UserHealthDataController extends ChangeNotifier {
  final UserHealthDataRepository _userHealthDataRepository;

  UserHealthDataController(this._userHealthDataRepository);

  bool _isLoading = false;
  String? _error;
  UserHealthData? _userHealthData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserHealthData? get userHealthData => _userHealthData;

  Future<bool> checkUserHasHealthData() => _userHealthDataRepository.checkUserHasHealthData();

  Future<void> upsertUserHealthData(UserHealthData userHealthDataDto) async {
    _setLoading(true);

    try {
      _userHealthData = await _userHealthDataRepository.upsertUserHealthData(userHealthDataDto);
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getUserHealthDataForPrediction(UserHealthData userHealthDataDto) async {
    _setLoading(true);

    try {
      _userHealthData = await _userHealthDataRepository.getUserHealthDataForPrediction();
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}