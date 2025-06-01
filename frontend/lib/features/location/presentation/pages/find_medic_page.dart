import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/location/presentation/widgets/medic_filter_panel.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/features/medics/presentation/controllers/medic_filtering_controller.dart';
import 'package:frontend/features/medics/data/repositories/medic_repository_impl.dart';
import 'package:frontend/features/medics/presentation/widgets/medic_list_view.dart';
import 'package:frontend/handlers/medic_assignment_handler.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';

class FindMedicPage extends StatefulWidget {
  const FindMedicPage({Key? key}) : super(key: key);

  @override
  State<FindMedicPage> createState() => _FindMedicPageState();
}

class _FindMedicPageState extends State<FindMedicPage> {
  final TextEditingController _cityCtrl    = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();

  late final MedicFilteringController _filterCtrl;
  late final MedicAssignmentHandler  _assignHandler;

  @override
  void initState() {
    super.initState();
    _filterCtrl = MedicFilteringController(MedicRepositoryImpl());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userController = context.read<UserController>();
    _assignHandler = MedicAssignmentHandler(userController);
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _filterCtrl.dispose();
    super.dispose();
  }

  void _assign(int id) async {
    try {
      await _assignHandler.assignMedic(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medic assigned successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign medic: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'Find a Medic'),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ChangeNotifierProvider<MedicFilteringController>.value(
                    value: _filterCtrl,
                    child: Consumer<MedicFilteringController>(
                      builder: (context, ctrl, _) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF).withValues(alpha: 38),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFFFFFF).withValues(alpha: 76),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: MedicFilterPanel(
                                    cityController: _cityCtrl,
                                    countryController: _countryCtrl,
                                    onFilterChanged: (_) {
                                      ctrl.getFilteredMedics(
                                        city: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
                                        country: _countryCtrl.text.isEmpty ? null : _countryCtrl.text,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Expanded(
                              child: ctrl.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ctrl.errorMessage != null
                                      ? Center(
                                          child: Text(
                                            ctrl.errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFFFFF).withValues(alpha: 38),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(0xFFFFFFFF).withValues(alpha: 76),
                                                  width: 1.5,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: MedicListView(
                                                medics: ctrl.filteredMedics,
                                                onAssign: _assign,
                                              ),
                                            ),
                                          ),
                                        ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}