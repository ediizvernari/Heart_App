import 'package:frontend/features/medical_services/data/models/medical_service.dart';
import 'package:frontend/features/medical_services/data/models/medical_service_type.dart';

abstract class MedicalServiceRepository {
  Future<List<MedicalServiceType>> getAllMedicalServiceTypes();
  Future<List<MedicalService>> getMyMedicalServices();
  Future<MedicalService> createMedicalService(MedicalService medicalService);
  Future<MedicalService> updateMedicalService(MedicalService medicalService);
  Future<void> deleteMedicalService(int medicalServiceId);
  Future<List<MedicalService>> getMedicalServicesByMedicId(int medicId);
}