import '../../../../core/api/api_client.dart';
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

  /// Hits the dev-only ad-grant endpoint. Returns slots granted by this
  /// single call (0 or 1).
  Future<int> watchAdStub() async {
    final response = await _client.post('/ad-views/dev-grant');
    final body = response.data as Map<String, dynamic>;
    return (body['slots_granted'] as num).toInt();
  }
}
