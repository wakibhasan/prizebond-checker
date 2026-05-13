import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

/// 50dp banner-ad slot anchored at the bottom of a page.
///
/// Pages drop a `const BannerAdHost()` into their Scaffold's
/// `bottomNavigationBar` slot. The slot reserves a fixed 50dp of vertical
/// space whether or not an ad is loaded, so there's no layout shift when
/// the ad arrives or fails.
class BannerAdHost extends StatefulWidget {
  const BannerAdHost({super.key});

  static const double height = 50;

  @override
  State<BannerAdHost> createState() => _BannerAdHostState();
}

class _BannerAdHostState extends State<BannerAdHost> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final unitId = AdUnitIds.banner;
    if (unitId.isEmpty) return;

    _ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: BannerAdHost.height,
        width: double.infinity,
        child: _loaded && _ad != null
            ? AdWidget(ad: _ad!)
            : const SizedBox.shrink(),
      ),
    );
  }
}
