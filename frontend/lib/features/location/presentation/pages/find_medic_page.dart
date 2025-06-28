import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/custom_app_bar.dart';

import 'package:frontend/features/medics/presentation/controllers/medic_filtering_controller.dart';
import 'package:frontend/features/medics/data/repositories/medic_repository_impl.dart';
import 'package:frontend/features/users/presentation/controllers/user_controller.dart';
import 'package:frontend/features/location/presentation/widgets/find_medic_body.dart';

class FindMedicPage extends StatefulWidget {
  const FindMedicPage({Key? key}) : super(key: key);

  @override
  State<FindMedicPage> createState() => _FindMedicPageState();
}

class _FindMedicPageState extends State<FindMedicPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  late final MedicFilteringController _filterCtrl;

  @override
  void initState() {
    super.initState();
    _filterCtrl = MedicFilteringController(MedicRepositoryImpl());
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _filterCtrl.dispose();
    super.dispose();
  }

  void _assign(int id) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final userCtrl = context.read<UserController>();
  try {
    await userCtrl.assignMedic(id);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Medic assigned successfully!')),
    );
    navigator.pop();
  } catch (e) {
    if (!mounted) return;
    messenger.showSnackBar(
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
          child: ChangeNotifierProvider<MedicFilteringController>.value(
            value: _filterCtrl,
            child: Column(
              children: [
                const CustomAppBar(title: 'Find a Medic'),
                Expanded(
                  child: FindMedicBody(
                    cityController: _cityController,
                    countryController: _countryController,
                    onAssign: _assign,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
