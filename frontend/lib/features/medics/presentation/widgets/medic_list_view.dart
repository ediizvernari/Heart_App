import 'package:flutter/material.dart';
import '../../data/models/medic.dart';
import 'medic_card.dart';

class MedicListView extends StatelessWidget {
  final List<Medic> medics;
  final ValueChanged<int> onAssign;

  const MedicListView({
    Key? key,
    required this.medics,
    required this.onAssign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medics.isEmpty) {
      return const Center(child: Text('No medics found.'));
    }
    return Expanded(
      child: ListView.builder(
        itemCount: medics.length,
        itemBuilder: (context, i) {
          final m = medics[i];
          return MedicCard(
            medic: m,
            onAssign: () => onAssign(m.id),
          );
        },
      ),
    );
  }
}
