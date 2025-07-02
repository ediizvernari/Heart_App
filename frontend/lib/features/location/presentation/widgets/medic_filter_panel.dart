import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class MedicFilter {
  final String? city;
  final String? country;

  MedicFilter({this.city, this.country});
}

class MedicFilterPanel extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController countryController;
  final ValueChanged<MedicFilter> onFilterChanged;

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
      final city = widget.cityController.text.trim().isEmpty
          ? null
          : widget.cityController.text.trim();
      final country = widget.countryController.text.trim().isEmpty
          ? null
          : widget.countryController.text.trim();

      widget.onFilterChanged(MedicFilter(city: city, country: country));
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
    widget.cityController.removeListener(_onAnyChange);
    widget.countryController.removeListener(_onAnyChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: widget.cityController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.countryController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
