import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../controllers/medic_filtering_controller.dart';
import '../../handlers/medic_assignment_handler.dart';
import '../../services/user_service.dart';
import '../../widgets/medic_filter_panel.dart';
import '../../widgets/medic_list_view.dart';

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
    _filterCtrl = MedicFilteringController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userService = context.read<UserService>();
    _assignHandler = MedicAssignmentHandler(userService);
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
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
      backgroundColor: AppColors.softGrey,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 120,
            color: AppColors.primaryRed,
            alignment: Alignment.center,
            child: Text(
              'Find a Medic',
              style: AppTextStyles.welcomeHeader.copyWith(
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ChangeNotifierProvider.value(
                value: _filterCtrl,
                child: Consumer<MedicFilteringController>(
                  builder: (_, ctrl, __) => Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: MedicFilterPanel(
                            cityController: _cityCtrl,
                            countryController: _countryCtrl,
                            onFilterChanged: (_) {
                              _filterCtrl.fetchFilteredMedics(
                                city: _cityCtrl.text.isEmpty
                                    ? null
                                    : _cityCtrl.text,
                                country: _countryCtrl.text.isEmpty
                                    ? null
                                    : _countryCtrl.text,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (ctrl.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (ctrl.errorMessage != null)
                        Center(
                          child: Text(
                            ctrl.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else
                        MedicListView(
                          medics: ctrl.filteredMedics,
                          onAssign: _assign,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}