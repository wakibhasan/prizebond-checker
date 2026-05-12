import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Thin wrapper around Dio that maps HTTP/network failures to typed exceptions.
/// Data sources call `client.get/post/...` instead of touching Dio directly,
/// which keeps the data layer free of Dio-specific error handling.
class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return _run(() => _dio.get(path, queryParameters: query));
  }

  Future<Response<dynamic>> post(String path, {Object? body, Map<String, dynamic>? query}) {
    return _run(() => _dio.post(path, data: body, queryParameters: query));
  }

  Future<Response<dynamic>> patch(String path, {Object? body}) {
    return _run(() => _dio.patch(path, data: body));
  }

  Future<Response<dynamic>> delete(String path) {
    return _run(() => _dio.delete(path));
  }

  Future<Response<dynamic>> _run(Future<Response<dynamic>> Function() op) async {
    try {
      return await op();
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Exception _toException(DioException e) {
    final type = e.type;
    if (type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return NetworkException(e.message ?? 'Connection error.');
    }

    final response = e.response;
    if (response == null) {
      return ServerException(message: e.message ?? 'Unknown error.');
    }

    final status = response.statusCode;
    final data = response.data;
    final raw = (data is Map<String, dynamic>) ? data : <String, dynamic>{};
    final message = (raw['message'] as String?) ?? 'Request failed.';
    final code = raw['code'] as String?;

    if (status == 401) {
      return AuthException(message);
    }
    return ServerException(
      message: message,
      statusCode: status,
      code: code,
      data: raw,
    );
  }
}
