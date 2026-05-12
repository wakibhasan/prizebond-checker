class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? data;

  ServerException({
    this.message = 'Server error.',
    this.statusCode,
    this.code,
    this.data,
  });
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error.']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed.']);
}
