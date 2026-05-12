part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  needsMobile,
  authenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
