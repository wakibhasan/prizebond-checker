import 'package:flutter/foundation.dart' show kDebugMode;

/// Centralised ad unit IDs.
///
/// **Banner:** Google's evergreen test unit in debug, your real unit in
/// release. Banner ads have no SSV verification, so the test unit is fine.
///
/// **Rewarded interstitial:** uses the real unit ID in *both* debug and
/// release. Google's universal test units don't fire SSV callbacks (they
/// belong to Google's AdMob account, not ours), so we'd have no way to
/// exercise the full reward-grant pipeline. Real unit + this phone
/// registered as an AdMob test device (see `main.dart`) gives us
/// test-style ads AND working SSV.
///
/// **Before interacting with any ad, verify the "Test Ad" label is
/// visible.** If it isn't, the test-device config didn't apply and you
/// could generate real invalid-traffic events. Stop and re-check.
class AdUnitIds {
  AdUnitIds._();

  // Google's evergreen test banner. Safe to commit.
  // https://developers.google.com/admob/android/test-ads
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';

  // TODO: paste your real banner unit ID before shipping.
  static const _releaseBanner = '';

  // Real rewarded interstitial — needed for SSV postbacks to fire.
  static const _rewardedInterstitial =
      'ca-app-pub-9043002840242025/9870552519';

  static String get banner => kDebugMode ? _testBanner : _releaseBanner;
  static String get rewardedInterstitial => _rewardedInterstitial;
}
