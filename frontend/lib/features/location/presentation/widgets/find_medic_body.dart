import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

import 'package:frontend/features/location/presentation/widgets/medic_filter_panel.dart';
import 'package:frontend/features/medics/presentation/widgets/medic_list_view.dart';
import 'package:frontend/features/medics/presentation/controllers/medic_filtering_controller.dart';

class FindMedicBody extends StatelessWidget {
  final TextEditingController cityController;
  final TextEditingController countryController;
  final void Function(int) onAssign;

  const FindMedicBody({
    Key? key,
    required this.cityController,
    required this.countryController,
    required this.onAssign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Consumer<MedicFilteringController>(
        builder: (context, locationController, _) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: MedicFilterPanel(
                      cityController: cityController,
                      countryController: countryController,
                      onFilterChanged: (_) {
                        locationController.getFilteredMedics(
                          city: cityController.text.isEmpty ? null : cityController.text,
                          country: countryController.text.isEmpty ? null : countryController.text,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: locationController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : locationController.errorMessage != null
                        ? Center(
                            child: Text(
                              locationController.errorMessage!,
                              style: AppTextStyles.errorText,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: MedicListView(
                                  medics: locationController.filteredMedics,
                                  onAssign: onAssign,
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
