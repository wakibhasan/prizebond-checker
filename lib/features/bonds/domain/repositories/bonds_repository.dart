import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bond.dart';
import '../entities/bond_quota.dart';
import '../entities/series.dart';

/// Returned from `addBond` when the server rejects with HTTP 403
/// `quota_exceeded`. Carries the live quota snapshot so the UI can route
/// straight into the ad-unlock flow without an extra API roundtrip.
class QuotaExceededFailure extends Failure {
  final BondQuota quota;
  const QuotaExceededFailure(super.message, this.quota);

  @override
  List<Object?> get props => [message, quota];
}

class DuplicateBondFailure extends Failure {
  const DuplicateBondFailure([super.message = 'You have already saved this bond.']);
}

abstract class BondsRepository {
  Future<Either<Failure, List<Bond>>> listBonds();
  Future<Either<Failure, List<Series>>> listSeries();
  Future<Either<Failure, BondQuota>> getQuota();
  Future<Either<Failure, Bond>> addBond({required String bondNumber});
  Future<Either<Failure, void>> deleteBond(int bondId);

  /// Stub that imitates the rewarded-ad flow by hitting the dev-only
  /// `/ad-views/dev-grant` endpoint. Returns the number of slots granted
  /// by this single watch (0 if not enough verified views yet, 1 if it
  /// completed a pair).
  Future<Either<Failure, int>> watchAdStub();
}
