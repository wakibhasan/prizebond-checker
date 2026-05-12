import '../../../../core/api/api_client.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  AuthRemoteDataSource(this._client);

  /// Returns `(token, user)` from `/auth/dev-login`.
  Future<({String token, AuthUserModel user})> devLogin({
    required String email,
    String? name,
  }) async {
    final response = await _client.post(
      '/auth/dev-login',
      body: {
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// Exchanges a Google-issued ID token for a Sanctum token via `/auth/google`.
  Future<({String token, AuthUserModel user})> googleLogin(String idToken) async {
    final response = await _client.post(
      '/auth/google',
      body: {'id_token': idToken},
    );
    final data = response.data as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthUserModel> getMe() async {
    final response = await _client.get('/me');
    final body = response.data as Map<String, dynamic>;
    return AuthUserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Updates name and/or mobile via `PATCH /me`. Pass `includeMobile: true`
  /// to send the `mobile` field — including a null value, which the server
  /// treats as "clear it". Without `includeMobile`, the field is omitted.
  Future<AuthUserModel> patchMe({
    String? name,
    String? mobile,
    bool includeMobile = false,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (includeMobile) body['mobile'] = mobile;

    final response = await _client.patch('/me', body: body);
    final json = response.data as Map<String, dynamic>;
    return AuthUserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }
}
