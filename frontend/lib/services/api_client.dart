import 'dart:convert';
import 'package:http/http.dart' as http;

class APIClient {
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return await http.get(
      Uri.parse(url),
      headers: headers
    );
  }

  static Future<http.Response> post(String url, dynamic body, {Map<String, String>? headers}) async {
    return await http.post(
      Uri.parse(url),
      headers: headers ?? {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String url, dynamic body, {Map<String, String>? headers}) async {
    return await http.patch(
      Uri.parse(url),
      headers: headers ?? {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
  }  
}
