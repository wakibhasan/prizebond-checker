import '../../../../core/api/api_client.dart';
import '../../domain/entities/ad_view_intent.dart';
import '../models/bond_model.dart';
import '../models/bond_quota_model.dart';
import '../models/series_model.dart';

class BondsRemoteDataSource {
  final ApiClient _client;
  BondsRemoteDataSource(this._client);

  Future<List<BondModel>> listBonds({int page = 1, int perPage = 50}) async {
    final response = await _client.get(
      '/bonds',
      query: {'page': page, 'per_page': perPage},
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['data'] as List;
    return items
        .map((e) => BondModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<SeriesModel>> listSeries() async {
    final response = await _client.get('/series');
    final body = response.data as Map<String, dynamic>;
    final items = body['data'] as List;
    return items
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<BondQuotaModel> getQuota() async {
    final response = await _client.get('/me/quota');
    return BondQuotaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BondModel> addBond({required String bondNumber}) async {
    final response = await _client.post(
      '/bonds',
      body: {'bond_number': bondNumber},
    );
    final body = response.data as Map<String, dynamic>;
    return BondModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBond(int bondId) async {
    await _client.delete('/bonds/$bondId');
  }

  /// Dev-only shortcut: hits `/ad-views/dev-grant`, which records a
  /// pre-verified ad view and runs the same slot-grant pipeline that SSV
  /// would. Returns the number of slots actually granted by this single
  /// call (0 or 1). Used as a fallback while AdMob account approval is
  /// pending — bypasses AdMob entirely.
  Future<int> grantDevSlot() async {
    final response = await _client.post('/ad-views/dev-grant');
    final body = response.data as Map<String, dynamic>;
    return (body['slots_granted'] as num).toInt();
  }

  /// Registers the *intent* to show a rewarded ad. The backend mints an
  /// `ad_views` row and returns identifiers the app passes to AdMob as
  /// `ServerSideVerificationOptions`, which AdMob then echoes back in the
  /// SSV postback.
  Future<AdViewIntent> registerAdView({
    String adFormat = 'rewarded_interstitial',
    String? adUnitId,
  }) async {
    final response = await _client.post(
      '/ad-views',
      body: {
        'ad_format': adFormat,
        if (adUnitId != null && adUnitId.isNotEmpty) 'ad_unit_id': adUnitId,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return AdViewIntent(
      adViewId: (body['ad_view_id'] as num).toInt(),
      ssvUserId: body['ssv_user_id'] as String,
      ssvCustomData: body['ssv_custom_data'] as String,
    );
  }
}
