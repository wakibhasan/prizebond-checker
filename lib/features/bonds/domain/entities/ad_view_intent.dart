/// Returned by the backend when the app registers its *intent* to show
/// a rewarded ad. These three values flow into AdMob's
/// `ServerSideVerificationOptions` so AdMob can echo them back in the SSV
/// postback — letting the backend correlate the postback to a specific
/// `ad_views` row.
class AdViewIntent {
  final int adViewId;
  final String ssvUserId;
  final String ssvCustomData;

  const AdViewIntent({
    required this.adViewId,
    required this.ssvUserId,
    required this.ssvCustomData,
  });
}
