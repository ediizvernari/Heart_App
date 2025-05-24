import 'package:frontend/features/location/data/model/city_country_suggestion.dart';

abstract class LocationRepository {
  Future<List<String>> getAllCountriesWithMedics();
  Future<List<CityCountrySuggestion>> getCityCountrySuggestions(String cityNameQuery);
}