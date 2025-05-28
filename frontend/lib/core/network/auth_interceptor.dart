import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/utils/auth_store.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final skipAuth = options.extra['noAuth'] == true;
    if (!skipAuth) {
      final token = await AuthStore.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await AuthStore.clearToken();

      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (_) => false);

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
    }
    handler.next(err);
  }
}