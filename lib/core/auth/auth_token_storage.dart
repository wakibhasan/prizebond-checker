import 'package:shared_preferences/shared_preferences.dart';

/// Stores the Sanctum bearer token. SharedPreferences is plaintext on disk;
/// for production we should swap this implementation for `flutter_secure_storage`.
abstract class AuthTokenStorage {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}

class AuthTokenStorageImpl implements AuthTokenStorage {
  static const _key = 'sanctum_token';
  final SharedPreferences _prefs;

  AuthTokenStorageImpl(this._prefs);

  @override
  Future<void> save(String token) async {
    await _prefs.setString(_key, token);
  }

  @override
  Future<String?> read() async {
    return _prefs.getString(_key);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
