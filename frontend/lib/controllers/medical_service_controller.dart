import 'package:flutter/foundation.dart';
import '../models/medical_service.dart';
import '../models/medical_service_type.dart';
import '../services/medical_service_api.dart';
import '../utils/auth_store.dart';

class MedicalServiceController extends ChangeNotifier {
  late AuthStore authStore;

  List<MedicalServiceType> _medicalServiceTypes = [];
  List<MedicalService> _medicalServices = [];
  bool _loadingTypes = false;
  bool _loadingServices = false;
  String? _error;

  List<MedicalServiceType> get types => List.unmodifiable(_medicalServiceTypes);
  List<MedicalService>    get services => List.unmodifiable(_medicalServices);
  bool get loadingTypes    => _loadingTypes;
  bool get loadingServices => _loadingServices;
  String? get error        => _error;

  Future<void> loadAllMedicalServiceData() async {
    await Future.wait([loadMedicalServiceTypes(), loadMedicalServices()]);
  }

  Future<void> loadMedicalServiceTypes() async {
    _loadingTypes = true;
    _error = null;
    notifyListeners();
    try {
      _medicalServiceTypes = await MedicalServiceApi.getAllMedicalServiceTypes();
    } catch (e) {
      _error = e.toString();
    }
    _loadingTypes = false;
    notifyListeners();
  }

  Future<void> loadMedicalServices() async {
    _loadingServices = true;
    _error = null;
    notifyListeners();

    final token = await AuthStore.getToken();
    if (token == null) {
      _error = 'Not authenticated – please log in.';
      _loadingServices = false;
      notifyListeners();
      return;
    }

    try {
      _medicalServices = await MedicalServiceApi.getMyMedicalServices(token);
    } catch (e) {
      _error = e.toString();
    }
    _loadingServices = false;
    notifyListeners();
  }

  Future<void> createMedicalService(MedicalService svc) async {
    _error = null;
    notifyListeners();

    final token = await AuthStore.getToken();
    if (token == null) {
      _error = 'Not authenticated – please log in.';
      notifyListeners();
      return;
    }

    try {
      final created = await MedicalServiceApi.createMedicalService(token, svc);
      _medicalServices.add(created);
      notifyListeners();
    } catch (e) {
      _error = 'createMedicalService error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchServicesForAssignedMedic(int medicId) async {
    _loadingServices = true;
    _error = null;
    notifyListeners();

    try {
      _medicalServices = await MedicalServiceApi.getMedicalServicesByMedicId(medicId);
    } catch (e) {
      _error = e.toString();
    }

    _loadingServices = false;
    notifyListeners();
  }

  Future<void> updateMedicalService(MedicalService svc) async {
    _error = null;
    notifyListeners();
    try {
      final token = await AuthStore.getToken();
      final updated = await MedicalServiceApi.updateMedicalService(token, svc);
      final index = _medicalServices.indexWhere((e) => e.id == updated.id);
      if (index != -1) _medicalServices[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMedicalService(int id) async {
    _error = null;
    notifyListeners();
    try {
      final token = await AuthStore.getToken();
      await MedicalServiceApi.deleteMedicalService(token, id);
      _medicalServices.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
