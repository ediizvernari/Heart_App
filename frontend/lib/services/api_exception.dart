import 'dart:convert';

class ApiException implements Exception {
  final int statusCode;
  final String responseBody;

  ApiException(this.statusCode, this.responseBody);

  String get message {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json['message'] as String? ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }

  @override
  String toString() =>
      'ApiException($statusCode): ${responseBody.replaceAll('\n', '')}';
}
