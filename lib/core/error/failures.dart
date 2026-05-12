import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? data;

  const ServerFailure(
    super.message, {
    this.statusCode,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, code, data];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
