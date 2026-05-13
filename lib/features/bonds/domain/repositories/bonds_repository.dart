import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ad_view_intent.dart';
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

  /// Registers the intent to show a rewarded ad. Call this *before* loading
  /// the AdMob ad — the returned identifiers must be set on the ad via
  /// `ServerSideVerificationOptions` so AdMob can echo them back in the
  /// SSV postback, letting the backend correlate the postback to the row.
  Future<Either<Failure, AdViewIntent>> registerAdView({
    String adFormat,
    String? adUnitId,
  });

  /// Dev-only: hits `/ad-views/dev-grant` to bypass AdMob and exercise the
  /// slot-grant pipeline directly. Returns slots granted (0 or 1).
  /// UI gates this behind `Env.devLoginEnabled`.
  Future<Either<Failure, int>> grantDevSlot();
}
