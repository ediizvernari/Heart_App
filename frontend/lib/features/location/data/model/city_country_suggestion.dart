class CityCountrySuggestion {
  final String city;
  final String country;

  CityCountrySuggestion({required this.city, required this.country});

  factory CityCountrySuggestion.fromJson(Map<String, dynamic> json) {
    return CityCountrySuggestion(
      city: json['city'] as String,
      country: json['country'] as String,
    );
  }
}
