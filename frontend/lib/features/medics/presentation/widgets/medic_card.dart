import 'package:flutter/material.dart';
import '../../data/models/medic.dart';

class MedicCard extends StatelessWidget {
  final Medic medic;
  final VoidCallback onAssign;

  const MedicCard({
    Key? key,
    required this.medic,
    required this.onAssign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${medic.firstName} ${medic.lastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Address: ${medic.streetAddress}'),
            Text('City: ${medic.city}'),
            Text('Country: ${medic.country}'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAssign,
                child: const Text('Assign Medic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
