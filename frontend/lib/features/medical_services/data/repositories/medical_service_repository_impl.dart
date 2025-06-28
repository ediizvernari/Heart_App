import 'package:frontend/features/medical_services/data/api/medical_service_api.dart';
import 'package:frontend/features/medical_services/data/models/medical_service.dart';
import 'package:frontend/features/medical_services/data/models/medical_service_type.dart';
import 'package:frontend/features/medical_services/data/repositories/medical_service_repository.dart';

class MedicalServiceRepositoryImpl implements MedicalServiceRepository {
  @override
  Future<List<MedicalServiceType>> getAllMedicalServiceTypes() {
    return MedicalServiceApi.getAllMedicalServiceTypes();
  }

  @override
  Future<List<MedicalService>> getMyMedicalServices() {
    return MedicalServiceApi.getMyMedicalServices();
  }

  @override
  Future<MedicalService> createMedicalService(MedicalService medicalService) {
    return MedicalServiceApi.createMedicalService(medicalService);
  }

  @override
  Future<MedicalService> updateMedicalService(MedicalService medicalService) {
    return MedicalServiceApi.updateMedicalService(medicalService);
  }

  @override
  Future<void> deleteMedicalService(int medicalServiceId) {
    return MedicalServiceApi.deleteMedicalService(medicalServiceId);
  }

  @override
  Future<List<MedicalService>> getMedicalServicesByMedicId(int medicId) {
    return MedicalServiceApi.getMedicalServicesByMedicId(medicId);
  }
}
