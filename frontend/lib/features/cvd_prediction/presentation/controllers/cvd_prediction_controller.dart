import 'package:flutter/material.dart';
import 'package:frontend/features/cvd_prediction/data/models/prediction_result.dart';
import 'package:frontend/features/cvd_prediction/data/repositories/cvd_prediction_repository.dart';
import 'package:frontend/features/user_health_data/data/models/user_health_data_model.dart';
import 'package:frontend/features/user_health_data/data/repositories/user_health_data_repository.dart';
import 'package:frontend/core/network/api_exception.dart';

class CvdPredictionController extends ChangeNotifier {
  final UserHealthDataRepository _userHealthDataRepository;
  final CvdPredictionRepository _cvdPredictionRepository;

  CvdPredictionController(this._userHealthDataRepository, this._cvdPredictionRepository);

  bool _isLoading = false;
  String? _error;
  UserHealthData? _userHealthData;
  PredictionResult? _cvdPredictionResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserHealthData? get userHealthData => _userHealthData;
  PredictionResult? get predictionResult => _cvdPredictionResult;

  Future<void> getUserHealthDataForPrediction() async {
    _setLoading(true);

    try {
      final userHasDataForPrediction = await _userHealthDataRepository.checkUserHasHealthData();

      if (userHasDataForPrediction) {
        _userHealthData = await _userHealthDataRepository.getUserHealthDataForPrediction();
      } else {
        _userHealthData = null;
      }
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> predictCvdProbability() async {
    _error = null;
    _cvdPredictionResult = null;
    notifyListeners();

    if(_userHealthData == null) {
      await getUserHealthDataForPrediction();
      if(_userHealthData == null) {
        _error = 'Health data is required for prediction.';
        notifyListeners();
        return;
      }
    }

    _setLoading(true);
    
    try {
      _cvdPredictionResult = await _cvdPredictionRepository.getCvdPredictionPercentage();
      _error = null;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
