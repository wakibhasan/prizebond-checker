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
    // Be lenient about missing fields. The 403 `quota_exceeded` response
    // historically omitted some of these — defaulting to 0 keeps the
    // parser from crashing the add-bond flow on an older backend.
    int asInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    return BondQuotaModel(
      currentBonds: asInt('current_bonds'),
      bondQuota: asInt('bond_quota'),
      adViewsUncredited: asInt('ad_views_uncredited'),
      adViewsPerSlot: asInt('ad_views_per_slot'),
      adsNeededForNextSlot: asInt('ads_needed_for_next_slot'),
      winsCount: asInt('wins_count'),
    );
  }
}
