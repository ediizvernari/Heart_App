import 'dart:async';
import 'package:flutter/material.dart';
import 'city_autocomplete_field.dart';

class MedicFilterPanel extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController countryController;
  final ValueChanged<String?> onFilterChanged;

  const MedicFilterPanel({
    Key? key,
    required this.cityController,
    required this.countryController,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<MedicFilterPanel> createState() => _MedicFilterPanelState();
}

class _MedicFilterPanelState extends State<MedicFilterPanel> {
  Timer? _debounce;

  void _onAnyChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onFilterChanged(null);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.cityController.addListener(_onAnyChange);
    widget.countryController.addListener(_onAnyChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CityAutocompleteField(controller: widget.cityController),
        const SizedBox(height: 12),
        TextField(
          controller: widget.countryController,
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
