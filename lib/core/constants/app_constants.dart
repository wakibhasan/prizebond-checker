class AppConstants {
  AppConstants._();

  static const String appName = 'Prize Bond Checker';

  // Bond storage rules
  static const int freeBondLimit = 5;
  static const int adViewsPerSlot = 2;

  // Backend (to be filled in once API exists)
  static const String apiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 20);

  // Local storage keys
  static const String prefsAuthToken = 'auth_token';
  static const String prefsUserId = 'user_id';
}
