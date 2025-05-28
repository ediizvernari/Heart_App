import 'package:frontend/features/medical_service/data/api/medical_service_api.dart';
import 'package:frontend/features/medical_service/data/models/medical_service.dart';
import 'package:frontend/features/medical_service/data/models/medical_service_type.dart';
import 'package:frontend/features/medical_service/data/repositories/medical_service_repository.dart';
import 'package:frontend/services/api_exception.dart';

class MedicalServiceRepositoryImpl implements MedicalServiceRepository {
  @override
  Future<List<MedicalServiceType>> getAllMedicalServiceTypes() async {
    try {
      return await MedicalServiceApi.getAllMedicalServiceTypes();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<MedicalService>> getMyMedicalServices() async {
    try {
      return await MedicalServiceApi.getMyMedicalServices();
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicalService> createMedicalService(MedicalService medicalService) async {
    try {
      return await MedicalServiceApi.createMedicalService(medicalService);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicalService> updateMedicalService(MedicalService medicalService) async {
    try {
      return await MedicalServiceApi.updateMedicalService(medicalService);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<void> deleteMedicalService(int medicalServiceId) async {
    try {
      return await MedicalServiceApi.deleteMedicalService(medicalServiceId);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<List<MedicalService>> getMedicalServicesByMedicId(int medicId) async {
    try {
      return await MedicalServiceApi.getMedicalServicesByMedicId(medicId);
    } on ApiException {
      rethrow;
    }
  }
}