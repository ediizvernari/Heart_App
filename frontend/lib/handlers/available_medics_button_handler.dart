import 'package:flutter/material.dart';
import '../views/screens/find_medic_page.dart'; // Make sure the path matches your folder structure

class AvailableMedicsButtonHandler {
  static void navigateToFindMedicPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FindMedicPage()),
    );
  }
}
