import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/validators/session_validator.dart';
import '../../controllers/medic_filtering_controller.dart';
import '../../handlers/medic_assignment_handler.dart';
import '../../services/user_service.dart';
import '../../widgets/medic_filter_panel.dart';
import '../../widgets/medic_list_view.dart';

class FindMedicPage extends StatefulWidget {
  const FindMedicPage({super.key});

  @override
  State<FindMedicPage> createState() => _FindMedicPageState();
}

class _FindMedicPageState extends State<FindMedicPage> {
  final TextEditingController _cityCtrl    = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();
  final _storage                        = const FlutterSecureStorage();

  late final MedicFilteringController _filterCtrl;
  MedicAssignmentHandler? _assignHandler;

  String? _token;
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _filterCtrl = MedicFilteringController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SessionValidator.verifyToken(context);
      final t = await _storage.read(key: 'auth_token');
      setState(() => _token = t);
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _assign(int id) async {
    if (_assignHandler == null) return;
    try {
      await _assignHandler!.assignMedic(id);
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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    _assignHandler ??= MedicAssignmentHandler(UserService(_token!));

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                city: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
                                country: _countryCtrl.text.isEmpty ? null : _countryCtrl.text,
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
