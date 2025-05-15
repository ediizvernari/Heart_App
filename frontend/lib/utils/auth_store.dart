import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../views/screens/auth/home_screen.dart';

class AuthStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_token';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  static Future<void> clearToken() =>
      _storage.delete(key: _key);

  static Future<String?> getToken() =>
      _storage.read(key: _key);

  static Future<bool> get isLoggedIn async {
    final token = await getToken();
    return token != null && !JwtDecoder.isExpired(token);
  }

  static Future<void> ensureSession(BuildContext context) async {
    final token = await getToken();
    if (token == null || JwtDecoder.isExpired(token)) {
      await clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  static Future<Map<String, dynamic>?> _getJwtPayload() async {
    final token = await getToken();
    if (token == null || JwtDecoder.isExpired(token)) return null;
    return JwtDecoder.decode(token);
  }

  static Future<int?> getTheIDOfTheCurrentAccount() async {
    final payload = await _getJwtPayload();
    if (payload == null) return null;
    final id = payload['sub'];
    return id is int ? id : int.tryParse(id?.toString() ?? '');
  }
}