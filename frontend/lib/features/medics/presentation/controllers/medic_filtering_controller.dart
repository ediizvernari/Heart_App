import 'package:flutter/material.dart';
import 'package:frontend/features/medics/data/repositories/medic_repository.dart';
import '../../data/models/medic.dart';

class MedicFilteringController extends ChangeNotifier {
  final MedicRepository _medicRepository;
  MedicFilteringController(this._medicRepository);

  List<Medic> _filteredMedics = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  List<Medic> get filteredMedics => _filteredMedics;
  String? get errorMessage => _errorMessage;

  Future<void> getFilteredMedics({String? city, String? country}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _filteredMedics = await _medicRepository.getFilteredMedicsByLocation(city, country);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
