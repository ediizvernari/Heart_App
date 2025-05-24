import 'package:flutter/material.dart';
import 'package:frontend/features/location/data/model/city_country_suggestion.dart';
import 'package:frontend/features/location/data/repositories/location_repository.dart';

class LocationController extends ChangeNotifier {
  final LocationRepository _locationRepository;

  LocationController(this._locationRepository);

  bool _isLoadingCountries = false;
  bool _isLoadingCitySuggestions = false;
  List<String> _countriesWithMedics = [];
  List<CityCountrySuggestion> _cityCountrySuggestions = [];
  String? _error;

  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingCitySuggestions => _isLoadingCitySuggestions;
  List<String> get countriesWithMedics => _countriesWithMedics;
  List<CityCountrySuggestion> get cityCountrySuggestions => _cityCountrySuggestions;
  String? get error => _error;

  Future<void> getAllCountriesWithMedics() async {
    _isLoadingCountries = true;
    _error = null;
    notifyListeners();

    try {
      _countriesWithMedics = await _locationRepository.getAllCountriesWithMedics();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  Future<void> suggestCitiesByName(String cityNameQuery) async {
    if (cityNameQuery.isEmpty) {
      _cityCountrySuggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingCitySuggestions = true;
    _error = null;
    notifyListeners();

    try {
      _cityCountrySuggestions = await _locationRepository.getCityCountrySuggestions(cityNameQuery);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCitySuggestions = false;
      notifyListeners();
    }
  }
}