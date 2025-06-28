import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/medical_service.dart';
import '../models/medical_service_type.dart';

class MedicalServiceApi {
  static final _noAuthOptions = Options(extra: {'noAuth': true});

  static Future<List<MedicalServiceType>> getAllMedicalServiceTypes() async {
    final response = await ApiClient.get<List<dynamic>>(
      APIConstants.getMedicalServicesTypesUrl,
      options: _noAuthOptions,
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
        .map((e) => MedicalServiceType.fromJson(e as Map<String, dynamic>))
        .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load medical service types.');
  }

  static Future<List<MedicalService>> getMyMedicalServices() async {
    final response = await ApiClient.get<List<dynamic>>(APIConstants.getMedicalServicesUrl);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
        .map((e) => MedicalService.fromJson(e as Map<String, dynamic>))
        .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load your medical services.');
  }

  static Future<MedicalService> createMedicalService(MedicalService service) async {
    final response = await ApiClient.post<Map<String, dynamic>>(
      APIConstants.createMedicalServiceUrl,
      service.toJsonForCreate(),
    );

    if (response.statusCode == 201 && response.data != null) {
      return MedicalService.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to create medical service.');
  }

  static Future<MedicalService> updateMedicalService(MedicalService service) async {
    final url = APIConstants.updateMedicalServiceUrl(service.id);
    final response = await ApiClient.patch<Map<String, dynamic>>(url, service.toJsonForCreate());

    if (response.statusCode == 200 && response.data != null) {
      return MedicalService.fromJson(response.data!);
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to update medical service.');
  }

  static Future<void> deleteMedicalService(int serviceId) async {
    final url = APIConstants.deleteMedicalServiceUrl(serviceId);
    final response = await ApiClient.delete<void>(url);

    if (response.statusCode == 200) return;

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to delete medical service.');
  }

  static Future<List<MedicalService>> getMedicalServicesByMedicId(int medicId) async {
    final url = APIConstants.getMedicalServicesByMedicIdUrl(medicId);
    final response = await ApiClient.get<List<dynamic>>(url, options: _noAuthOptions);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
        .map((e) => MedicalService.fromJson(e as Map<String, dynamic>))
        .toList();
    }

    throw ApiException(response.statusCode ?? 0, response.statusMessage ?? 'Failed to load services for medic $medicId.');
  }
}
