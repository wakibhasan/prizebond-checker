import '../../../../core/api/api_client.dart';
import '../models/win_model.dart';

class WinsRemoteDataSource {
  final ApiClient _client;
  WinsRemoteDataSource(this._client);

  Future<List<WinModel>> listWins({int page = 1, int perPage = 50}) async {
    final response = await _client.get(
      '/wins',
      query: {'page': page, 'per_page': perPage},
    );
    final body = response.data as Map<String, dynamic>;
    final items = body['data'] as List;
    return items
        .map((e) => WinModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
