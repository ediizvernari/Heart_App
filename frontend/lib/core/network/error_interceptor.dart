import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    if (res != null) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ApiException(
            res.statusCode ?? -1,
            res.statusMessage ?? err.message!,
          ),
          response: res,
          type: err.type,
        ),
      );
    } else {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ApiException(-1, err.message ?? 'Unknown error'),
          type: err.type,
        ),
      );
    }
  }
}
