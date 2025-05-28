import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
}
