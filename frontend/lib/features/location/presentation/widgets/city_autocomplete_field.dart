import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/location/presentation/controller/location_controller.dart';
import '../../data/model/city_country_suggestion.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  const CityAutocompleteField({Key? key, required this.controller})
      : super(key: key);

  @override
  _CityAutocompleteFieldState createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  @override
  Widget build(BuildContext context) {
    final locationController = context.read<LocationController>();

    return Autocomplete<CityCountrySuggestion>(
      displayStringForOption: (s) => s.city,

      optionsBuilder: (TextEditingValue textEditingValue) async {
        final input = textEditingValue.text;
        if (input.length < 2) return const <CityCountrySuggestion>[];
        await locationController.suggestCitiesByName(input);
        return locationController.cityCountrySuggestions;
      },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final suggestion = options.elementAt(i);
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

      onSelected: (selection) {
        widget.controller.text = selection.city;
        debugPrint('Selected country: ${selection.country}');
      },

      fieldViewBuilder: (context, textCtr, focusNode, onFieldSubmitted) {
        return TextField(
          controller: widget.controller,
          style: const TextStyle(color: AppColors.textPrimary),
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }
}