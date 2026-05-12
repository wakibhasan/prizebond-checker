import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/next_draw.dart';
import '../../domain/repositories/draws_repository.dart';
import '../datasources/draws_remote_datasource.dart';

class DrawsRepositoryImpl implements DrawsRepository {
  final DrawsRemoteDataSource _remote;
  DrawsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, NextDraw>> getNextDraw() async {
    try {
      final draw = await _remote.getNextDraw();
      return Right(draw);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
