import 'dart:convert';
import 'api_client.dart';
import '../core/api_constants.dart';
import '../models/city_country_suggestion.dart';


class LocationService {
  Future<List<String>> fetchAllCountriesWithMedics() async {
    final response = await APIClient.get(APIConstants.getCountriesUrl);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch countries: ${response.body}');
    }

    final countriesWithMedics = jsonDecode(response.body) as List<dynamic>;
    return countriesWithMedics.map((e) => e['name'] as String).toList();
  }

  Future<List<CityCountrySuggestion>> fetchCityCountrySuggestions(String partialCityName) async {
    final uri = Uri.parse(APIConstants.autocompleteCitiesUrl).replace(queryParameters: {'query': partialCityName});

    final response = await APIClient.get(uri.toString());

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch city-country suggestions: ${response.body}');
    }

    final cityCountrySuggestionItems = jsonDecode(response.body) as List<dynamic>;
    return cityCountrySuggestionItems.cast<Map<String, dynamic>>()
        .map(CityCountrySuggestion.fromJson)
        .toList();
  }
}
