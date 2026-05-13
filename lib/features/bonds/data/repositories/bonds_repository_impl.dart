import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ad_view_intent.dart';
import '../../domain/entities/bond.dart';
import '../../domain/entities/bond_quota.dart';
import '../../domain/entities/series.dart';
import '../../domain/repositories/bonds_repository.dart';
import '../datasources/bonds_remote_datasource.dart';
import '../models/bond_quota_model.dart';

class BondsRepositoryImpl implements BondsRepository {
  final BondsRemoteDataSource _remote;
  BondsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Bond>>> listBonds() async {
    try {
      final bonds = await _remote.listBonds();
      return Right(bonds);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Series>>> listSeries() async {
    try {
      final series = await _remote.listSeries();
      return Right(series);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, BondQuota>> getQuota() async {
    try {
      final quota = await _remote.getQuota();
      return Right(quota);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Bond>> addBond({required String bondNumber}) async {
    try {
      final bond = await _remote.addBond(bondNumber: bondNumber);
      return Right(bond);
    } on ServerException catch (e) {
      // Special-case the two known business errors so the UI can branch
      // without inspecting raw JSON.
      if (e.statusCode == 403 && e.code == 'quota_exceeded') {
        final quota = BondQuotaModel.fromJson(e.data ?? const {});
        return Left(QuotaExceededFailure(e.message, quota));
      }
      if (e.statusCode == 409 && e.code == 'duplicate_bond') {
        return Left(DuplicateBondFailure(e.message));
      }
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBond(int bondId) async {
    try {
      await _remote.deleteBond(bondId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AdViewIntent>> registerAdView({
    String adFormat = 'rewarded_interstitial',
    String? adUnitId,
  }) async {
    try {
      final intent = await _remote.registerAdView(
        adFormat: adFormat,
        adUnitId: adUnitId,
      );
      return Right(intent);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> grantDevSlot() async {
    try {
      final slots = await _remote.grantDevSlot();
      return Right(slots);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
