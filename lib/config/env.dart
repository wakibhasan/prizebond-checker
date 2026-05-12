import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to runtime environment variables loaded from `.env`.
class Env {
  Env._();

  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'http://10.0.2.2:8000';

  static String get apiV1BaseUrl => '$apiBaseUrl/api/v1';

  static bool get devLoginEnabled =>
      (dotenv.maybeGet('ENABLE_DEV_LOGIN') ?? 'false').toLowerCase() == 'true';

  /// Web OAuth client ID. Passed as `serverClientId` to GoogleSignIn so
  /// the returned ID token's `aud` claim matches what the backend verifies.
  static String get googleClientId => dotenv.maybeGet('GOOGLE_CLIENT_ID') ?? '';

  static bool get googleSignInConfigured => googleClientId.isNotEmpty;
}
