import 'dart:convert';
import 'package:frontend/services/api_exception.dart';

import '../../../../services/api_client.dart';
import '../../../../core/api_constants.dart';
import '../model/city_country_suggestion.dart';


class LocationApi {
  static Future<List<String>> getAllCountriesWithMedics() async {
    final response = await APIClient.get(APIConstants.getCountriesUrl);
    
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    final countriesWithMedics = jsonDecode(response.body) as List<dynamic>;
    return countriesWithMedics.map((e) => e['name'] as String).toList();
  }

  static Future<List<CityCountrySuggestion>> getCityCountrySuggestions(String cityNameQuery) async {
    final uri = Uri.parse(APIConstants.autocompleteCitiesUrl).replace(queryParameters: {'query': cityNameQuery});

    final response = await APIClient.get(uri.toString());

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    return (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>()
        .map(CityCountrySuggestion.fromJson)
        .toList();
  }
}
