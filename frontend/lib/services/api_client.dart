import 'dart:convert';
import 'package:http/http.dart' as http;

class APIClient {
  static final _client = http.Client();

  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return await _client.get(
      Uri.parse(url),
      headers: headers
    );
  }

  static Future<http.Response> post(String url,  dynamic body, {Map<String, String>? headers}) async {
    return await _client.post(
      Uri.parse(url),
      headers: headers ?? {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
  }
}