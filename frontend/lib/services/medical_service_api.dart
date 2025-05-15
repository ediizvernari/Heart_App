import 'dart:convert';
import '../core/api_constants.dart';
import 'api_client.dart';
import '../models/medical_service.dart';
import '../models/medical_service_type.dart';

class MedicalServiceApi{
  static Future<List<MedicalServiceType>> getAllMedicalServiceTypes() async {
    final response = await APIClient.get(APIConstants.getMedicalServicesTypesUrl);

    if (response.statusCode != 200) {
      throw Exception('Failed to load medical service types');
    }

    final List data = jsonDecode(response.body);
    return data
    .map((e) => MedicalServiceType.fromJson(e))
    .toList();
  }

  //Used by the medics
  static Future<List<MedicalService>> getMyMedicalServices(String? token) async {
    final headers = {'Authorization': 'Bearer $token'};
    final response = await APIClient.get(APIConstants.getMedicalServicesUrl, headers: headers);

    if (response.statusCode != 200){
      throw Exception('Failed to load medical services');
    }
    final List data = jsonDecode(response.body);
    return data
    .map((e) => MedicalService.fromJson(e))
    .toList();
  }

  static Future<MedicalService> createMedicalService(String token, MedicalService medicalService) async {
    const url = APIConstants.createMedicalServiceUrl;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final payload = medicalService.toJsonForCreate();
    print('createMedicalService payload: $payload');
    final response = await APIClient.post(url, payload, headers: headers);

   if (response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);  
    } 

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return MedicalService.fromJson(json);
  }

  static Future<MedicalService> updateMedicalService(String? token, MedicalService medicalService) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final url = APIConstants.updateMedicalServiceUrl(medicalService.id);
    final response = await APIClient.patch(url, medicalService.toJsonForCreate(), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to update medical service');
    }

    return MedicalService.fromJson(jsonDecode(response.body));
  }

  static Future<void> deleteMedicalService(String? token, int medicalServiceId) async {
    final headers = {'Authorization': 'Bearer $token'};
    final url = APIConstants.deleteMedicalServiceUrl(medicalServiceId);
    final response = await APIClient.delete(url, null, headers: headers);

    if(response.statusCode != 200) {
      throw Exception('Failed to delete medical service (status: ${response.statusCode})');
    }
  }

  static Future<List<MedicalService>> getMedicalServicesByMedicId(int medicId) async {
    final url = APIConstants.getMedicalServicesByMedicIdUrl(medicId);
    final response = await APIClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load services for medic $medicId');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => MedicalService.fromJson(e)).toList();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String responseBody;

  ApiException(this.statusCode, this.responseBody);

  @override
  String toString() =>
      'ApiException($statusCode): ${responseBody.replaceAll('\n', ' ')}';
}
