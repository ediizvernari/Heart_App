import 'package:flutter/foundation.dart';
import 'package:frontend/features/medical_service/data/repositories/medical_service_repository.dart';
import 'package:frontend/services/api_exception.dart';
import '../../data/models/medical_service.dart';
import '../../data/models/medical_service_type.dart';

class MedicalServiceController extends ChangeNotifier {
  final MedicalServiceRepository _medicalServiceRepository;

  MedicalServiceController(this._medicalServiceRepository);

  List<MedicalServiceType> _medicalServiceTypes = [];
  List<MedicalService> _medicalServices = [];
  bool _isLoadingTypes = false;
  bool _isLoadingServices = false;
  String? _error;

  List<MedicalServiceType> get medicalServiceTypes => List.unmodifiable(_medicalServiceTypes);
  List<MedicalService>    get medicalServices => List.unmodifiable(_medicalServices);
  bool get loadingTypes    => _isLoadingTypes;
  bool get loadingServices => _isLoadingServices;
  String? get error        => _error;

  Future<void> getAllMedicalServiceData() async {
    await Future.wait([getAllMedicalServiceTypes(), getMyMedicalServices()]);
  }

  Future<void> getAllMedicalServiceTypes() async {
    _isLoadingTypes = true;
    _error = null;
    notifyListeners();

    try {
      _medicalServiceTypes = await _medicalServiceRepository.getAllMedicalServiceTypes();
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingTypes = false;
      notifyListeners();
    }
  }

  Future<void> getMyMedicalServices() async {
    _isLoadingServices = true;
    _error = null;
    notifyListeners();

    try {
      _medicalServices = await _medicalServiceRepository.getMyMedicalServices();
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  Future<void> createMedicalService(MedicalService medicalService) async {
    _isLoadingServices = true;
    _error = null;
    notifyListeners();

    try {
      final MedicalService createdMedicalService = await _medicalServiceRepository.createMedicalService(medicalService);
      _medicalServices.add(createdMedicalService);
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  Future<void> getMedicalServicesForAssignedMedic(int medicId) async {
    _isLoadingServices = true;
    _error = null;
    notifyListeners();

    try {
      _medicalServices = await _medicalServiceRepository.getMedicalServicesByMedicId(medicId);
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  Future<void> updateMedicalService(MedicalService svc) async {
    _error = null;
    notifyListeners();

    try {
      final updated = await _medicalServiceRepository.updateMedicalService(svc);
      final idx = _medicalServices.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _medicalServices[idx] = updated;
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteMedicalService(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _medicalServiceRepository.deleteMedicalService(id);
      _medicalServices.removeWhere((e) => e.id == id);
    } on ApiException catch (e) {
      _error = e.responseBody;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
