class ApiException implements Exception {
  final int statusCode;
  final String responseBody;
  ApiException(this.statusCode, this.responseBody);
  @override
  String toString() =>
      'ApiException($statusCode): ${responseBody.replaceAll('\n', '')}';
}