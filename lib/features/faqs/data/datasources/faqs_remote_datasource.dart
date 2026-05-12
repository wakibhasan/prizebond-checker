import '../../../../core/api/api_client.dart';
import '../models/faq_model.dart';

class FaqsRemoteDataSource {
  final ApiClient _client;
  FaqsRemoteDataSource(this._client);

  Future<List<FaqModel>> listFaqs() async {
    final response = await _client.get('/faqs');
    final body = response.data as Map<String, dynamic>;
    final items = body['data'] as List;
    return items
        .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
