import 'package:dio/dio.dart';
import 'package:frontend/core/network/auth_interceptor.dart';
import 'package:frontend/core/network/error_interceptor.dart';

class ApiClient {
  static final Dio dioInstance = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  )
    ..interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);

  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
   dioInstance.get<T>(path, queryParameters: queryParameters, options: options);

  static Future<Response<T>> post<T>(String url, dynamic data, {Map<String, dynamic>? queryParameters, Options? options}) => 
    dioInstance.post<T>(url, data: data, queryParameters: queryParameters, options: options);

  static Future<Response<T>> patch<T>(String url, dynamic data, {Map<String, dynamic>? queryParameters, Options? options}) =>
    dioInstance.patch<T>(url, data: data, queryParameters: queryParameters, options: options);

  static Future<Response<T>> delete<T>(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) => 
    dioInstance.delete<T>(url, data: data, queryParameters: queryParameters, options: options);
}

