import 'package:dio/dio.dart';
import 'package:frontend/features/location/data/model/city_country_suggestion.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class LocationApi {
  static Future<List<String>> getAllCountriesWithMedics() async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.getCountriesUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load countries with medics.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }

  static Future<List<CityCountrySuggestion>> getCityCountrySuggestions(
      String cityNameQuery) async {
    try {
      final Response<List<dynamic>> response = await ApiClient.get<List<dynamic>>(APIConstants.autocompleteCitiesUrl, queryParameters: {'query': cityNameQuery}, options: Options(extra: {'noAuth': true}));

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .cast<Map<String, dynamic>>()
            .map(CityCountrySuggestion.fromJson)
            .toList();
      }

      throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load city suggestions.');
    } on DioException catch (dioError) {
      final int statusCode = dioError.response?.statusCode ?? -1;
      final String? errorMessage = dioError.response?.statusMessage ?? dioError.message;
      throw ApiException(statusCode, errorMessage!);
    }
  }
}
