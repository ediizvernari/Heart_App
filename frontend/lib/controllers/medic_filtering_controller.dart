import 'package:flutter/material.dart';
import '../models/medic.dart';
import '../services/medic_service.dart';

class MedicFilteringController extends ChangeNotifier {
  List<Medic> _filteredMedics = [];
  bool _isLoading = false;
  String? _errorMessage;

  MedicFilteringController(); 
  
  bool get isLoading => _isLoading;
  List<Medic> get filteredMedics => _filteredMedics;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFilteredMedics({
    String? city,
    String? country,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _filteredMedics = await MedicService.fetchFilteredMedics(city: city, country: country);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
