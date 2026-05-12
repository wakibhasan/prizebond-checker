import '../../domain/entities/bond_quota.dart';

class BondQuotaModel extends BondQuota {
  const BondQuotaModel({
    required super.currentBonds,
    required super.bondQuota,
    required super.adViewsUncredited,
    required super.adViewsPerSlot,
    required super.adsNeededForNextSlot,
    required super.winsCount,
  });

  factory BondQuotaModel.fromJson(Map<String, dynamic> json) {
    return BondQuotaModel(
      currentBonds: (json['current_bonds'] as num).toInt(),
      bondQuota: (json['bond_quota'] as num).toInt(),
      adViewsUncredited: (json['ad_views_uncredited'] as num).toInt(),
      adViewsPerSlot: (json['ad_views_per_slot'] as num).toInt(),
      adsNeededForNextSlot: (json['ads_needed_for_next_slot'] as num).toInt(),
      // `wins_count` was added later — default to 0 if the server doesn't
      // include it (e.g. an older 403 quota_exceeded payload).
      winsCount: (json['wins_count'] as num?)?.toInt() ?? 0,
    );
  }
}
