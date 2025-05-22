import 'package:frontend/features/medical_service/data/api/medical_service_api.dart';
import 'package:frontend/features/medical_service/data/models/medical_service.dart';
import 'package:frontend/features/medical_service/data/models/medical_service_type.dart';
import 'package:frontend/features/medical_service/data/repositories/medical_service_repository.dart';
import 'package:frontend/services/api_exception.dart';
import 'package:frontend/utils/auth_store.dart';

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
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicalServiceApi.getMyMedicalServices(token);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicalService> createMedicalService(MedicalService medicalService) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicalServiceApi.createMedicalService(token, medicalService);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<MedicalService> updateMedicalService(MedicalService medicalService) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicalServiceApi.updateMedicalService(token, medicalService);
    } on ApiException {
      rethrow;
    }
  }

  @override
  Future<void> deleteMedicalService(int medicalServiceId) async {
    final token = await AuthStore.getToken();
    if(token == null) throw ApiException(401, 'Missing auth token');

    try {
      return await MedicalServiceApi.deleteMedicalService(token, medicalServiceId);
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