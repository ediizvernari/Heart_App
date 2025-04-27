import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/city_country_suggestion.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  const CityAutocompleteField({Key? key, required this.controller})
      : super(key: key);

  @override
  _CityAutocompleteFieldState createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Autocomplete<CityCountrySuggestion>(
      displayStringForOption: (CityCountrySuggestion s) => s.city,

      optionsBuilder: (TextEditingValue textEditingValue) async {
        final input = textEditingValue.text;
        if (input.length < 2) return const [];
        return await _locationService.fetchCityCountrySuggestions(input);
      },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final suggestion = options.elementAt(index);
                  return ListTile(
                    title: Text(suggestion.city),
                    subtitle: Text(suggestion.country),
                    onTap: () => onSelected(suggestion),
                  );
                },
              ),
            ),
          ),
        );
      },

      onSelected: (CityCountrySuggestion selection) {
        widget.controller.text = selection.city;
        debugPrint('Selected country: ${selection.country}');
      },

      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (String value) => onFieldSubmitted(),
        );
      },
    );
  }
}
