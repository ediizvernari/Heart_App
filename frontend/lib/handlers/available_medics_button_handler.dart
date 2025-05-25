import 'package:flutter/material.dart';

class AvailableMedicsButtonHandler {
  static Future<T?> navigateToFindMedicPage<T>(BuildContext context) {
  // Return the Future from pushNamed so callers can await.
    return Navigator.pushNamed<T>(context, '/find-medic');
  }
}