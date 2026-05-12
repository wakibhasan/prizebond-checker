import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  /// Whether a Sanctum token exists locally (does not validate it server-side).
  Future<bool> hasLocalToken();

  /// Hits `/auth/dev-login` to mint a token without Google. Dev-only.
  Future<Either<Failure, AuthUser>> devSignIn({
    required String email,
    String? name,
  });

  /// Exchanges a Google ID token for a Sanctum token via `/auth/google`.
  Future<Either<Failure, AuthUser>> googleSignIn(String idToken);

  /// Fetches the current authenticated user from `/me`.
  Future<Either<Failure, AuthUser>> getCurrentUser();

  /// Updates name and/or mobile via `PATCH /me`.
  Future<Either<Failure, AuthUser>> updateProfile({
    String? name,
    String? mobile,
  });

  /// Calls `/auth/logout` and clears the local token.
  Future<Either<Failure, void>> signOut();
}
