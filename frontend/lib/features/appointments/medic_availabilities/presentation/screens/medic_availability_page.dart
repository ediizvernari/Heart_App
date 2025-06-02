import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/medic_availabilities/presentation/widgets/medic_availability_body.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/medic_availability_controller.dart';
import '../widgets/new_slot_dialog.dart';

class MedicAvailabilityPage extends StatefulWidget {
  const MedicAvailabilityPage({Key? key}) : super(key: key);

  @override
  _MedicAvailabilityPageState createState() => _MedicAvailabilityPageState();
}

class _MedicAvailabilityPageState extends State<MedicAvailabilityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicAvailabilityController>().getMyAvailabilities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicAvailabilityController>();

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: 'Availability Management'),
      ),
      body: AvailabilityBody(controller: controller),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: const NewSlotDialog(),
            ),
          );
        },
      ),
    );
  }
}
