import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../features/auth/presentation/screens/home_screen.dart';
import '../views/screens/user_main_page.dart';
import '../views/screens/medic_main_page.dart';

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
    debugPrint('AuthStore.ensureSession: starting session check');

    final token = await getToken();
    debugPrint('AuthStore.ensureSession: raw token = $token');

    if (token == null) {
      debugPrint('AuthStore.ensureSession: no token found, redirecting to HomeScreen');
      await clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
      return;
    }

    final expired = JwtDecoder.isExpired(token);
    debugPrint('AuthStore.ensureSession: token expired? $expired');

    if (expired) {
      debugPrint('AuthStore.ensureSession: token expired, clearing and redirecting to HomeScreen');
      await clearToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
      return;
    }

    final payload = JwtDecoder.decode(token);
    final role = payload['role'] as String?;
    debugPrint('AuthStore.ensureSession: decoded payload = $payload');
    debugPrint('AuthStore.ensureSession: user role = $role');

    Widget next;
    if (role == 'medic') {
      debugPrint('AuthStore.ensureSession: navigating to MedicMainPage');
      next = const MedicMainPage();
    } else {
      debugPrint('AuthStore.ensureSession: navigating to UserMainPage');
      next = const UserMainPage();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (_) => false,
    );
    debugPrint('AuthStore.ensureSession: navigation complete');
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
