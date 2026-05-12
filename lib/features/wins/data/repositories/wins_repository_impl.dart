import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/win.dart';
import '../../domain/repositories/wins_repository.dart';
import '../datasources/wins_remote_datasource.dart';

class WinsRepositoryImpl implements WinsRepository {
  final WinsRemoteDataSource _remote;
  WinsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Win>>> listWins() async {
    try {
      final wins = await _remote.listWins();
      return Right(wins);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
