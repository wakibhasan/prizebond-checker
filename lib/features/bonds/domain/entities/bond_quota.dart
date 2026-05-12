import 'package:equatable/equatable.dart';

/// Snapshot of the user's bond-storage budget. Drives the "X / Y bonds"
/// indicator and the ad-unlock prompt.
class BondQuota extends Equatable {
  final int currentBonds;
  final int bondQuota;
  final int adViewsUncredited;
  final int adViewsPerSlot;
  final int adsNeededForNextSlot;
  final int winsCount;

  const BondQuota({
    required this.currentBonds,
    required this.bondQuota,
    required this.adViewsUncredited,
    required this.adViewsPerSlot,
    required this.adsNeededForNextSlot,
    required this.winsCount,
  });

  bool get isAtCapacity => currentBonds >= bondQuota;
  int get remaining => bondQuota - currentBonds;

  @override
  List<Object?> get props => [
        currentBonds,
        bondQuota,
        adViewsUncredited,
        adViewsPerSlot,
        adsNeededForNextSlot,
        winsCount,
      ];
}
