import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  /// Called once at app startup. Checks for a stored token and tries to
  /// resolve the current user from the server.
  Future<void> bootstrap() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final hasToken = await _repository.hasLocalToken();
    if (!hasToken) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
      return;
    }

    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: user.hasMobile ? AuthStatus.authenticated : AuthStatus.needsMobile,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> devSignIn({required String email, String? name}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _repository.devSignIn(email: email, name: name);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: user.hasMobile ? AuthStatus.authenticated : AuthStatus.needsMobile,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> googleSignIn(String idToken) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _repository.googleSignIn(idToken);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: user.hasMobile ? AuthStatus.authenticated : AuthStatus.needsMobile,
        user: user,
        clearError: true,
      )),
    );
  }

  /// Surface a client-side Google Sign-In failure (cancel / network / SDK
  /// init issue) the same way a backend rejection would look.
  void reportSignInError(String message) {
    emit(state.copyWith(
      status: AuthStatus.error,
      errorMessage: message,
    ));
  }

  Future<void> submitMobile(String mobile) async {
    final current = state.user;
    if (current == null) return;

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _repository.updateProfile(mobile: mobile);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.needsMobile,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: user.hasMobile ? AuthStatus.authenticated : AuthStatus.needsMobile,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> updateName(String name) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _repository.updateProfile(name: name);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
