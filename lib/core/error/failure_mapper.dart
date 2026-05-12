import 'exceptions.dart';
import 'failures.dart';

/// Maps an exception thrown by ApiClient into a domain-layer Failure.
/// Repository implementations call this in their catch blocks to keep the
/// translation in one place.
Failure mapExceptionToFailure(Object e) {
  if (e is NetworkException) {
    return NetworkFailure(e.message);
  }
  if (e is AuthException) {
    return AuthFailure(e.message);
  }
  if (e is ServerException) {
    if (e.statusCode == 422) {
      final raw = e.data?['errors'];
      Map<String, List<String>>? fieldErrors;
      if (raw is Map<String, dynamic>) {
        fieldErrors = raw.map(
          (k, v) => MapEntry(k, (v as List).map((x) => x.toString()).toList()),
        );
      }
      return ValidationFailure(e.message, fieldErrors: fieldErrors);
    }
    return ServerFailure(
      e.message,
      statusCode: e.statusCode,
      code: e.code,
      data: e.data,
    );
  }
  if (e is CacheException) {
    return CacheFailure(e.message);
  }
  return UnexpectedFailure(e.toString());
}
