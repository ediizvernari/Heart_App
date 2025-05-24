import 'package:frontend/features/location/data/api/location_api.dart';
import 'package:frontend/features/location/data/model/city_country_suggestion.dart';
import 'package:frontend/features/location/data/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<List<String>> getAllCountriesWithMedics() async {
    return await LocationApi.getAllCountriesWithMedics();
  }

  @override
  Future<List<CityCountrySuggestion>> getCityCountrySuggestions(String cityNameQuery) async {
    return await LocationApi.getCityCountrySuggestions(cityNameQuery);
  }
}