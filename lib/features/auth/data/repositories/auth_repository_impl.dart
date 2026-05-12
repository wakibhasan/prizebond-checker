import 'package:dartz/dartz.dart';

import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthTokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remote, this._tokenStorage);

  @override
  Future<bool> hasLocalToken() async {
    final token = await _tokenStorage.read();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<Failure, AuthUser>> devSignIn({
    required String email,
    String? name,
  }) async {
    try {
      final result = await _remote.devLogin(email: email, name: name);
      await _tokenStorage.save(result.token);
      return Right(result.user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> googleSignIn(String idToken) async {
    try {
      final result = await _remote.googleLogin(idToken);
      await _tokenStorage.save(result.token);
      return Right(result.user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getCurrentUser() async {
    try {
      final user = await _remote.getMe();
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> updateProfile({
    String? name,
    String? mobile,
  }) async {
    try {
      final user = await _remote.patchMe(
        name: name,
        mobile: mobile,
        includeMobile: true,
      );
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Whatever happens server-side, clear local state — we want to land
      // on the sign-in screen.
    }
    await _tokenStorage.clear();
    return const Right(null);
  }
}
