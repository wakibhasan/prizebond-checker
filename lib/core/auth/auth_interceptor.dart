import 'package:dio/dio.dart';

import 'auth_token_storage.dart';

/// Attaches the stored Sanctum token to every outgoing request.
/// On a 401 response, clears the stored token so the app falls back to the
/// sign-in screen the next time it checks auth state.
class AuthInterceptor extends Interceptor {
  final AuthTokenStorage _storage;
  final Future<void> Function()? _onUnauthorized;

  AuthInterceptor(this._storage, {Future<void> Function()? onUnauthorized})
      : _onUnauthorized = onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clear();
      if (_onUnauthorized != null) {
        await _onUnauthorized();
      }
    }
    handler.next(err);
  }
}
