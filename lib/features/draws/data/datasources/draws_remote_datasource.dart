import '../../../../core/api/api_client.dart';
import '../models/next_draw_model.dart';

class DrawsRemoteDataSource {
  final ApiClient _client;
  DrawsRemoteDataSource(this._client);

  Future<NextDrawModel> getNextDraw() async {
    final response = await _client.get('/draws/next');
    return NextDrawModel.fromJson(response.data as Map<String, dynamic>);
  }
}
