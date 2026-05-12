import 'package:flutter/material.dart';

/// 50dp banner-ad slot anchored at the bottom of a page.
///
/// **Today this renders a styled placeholder** — a thin grey bar with an
/// "Ad" tag — so the layout stays honest about where ads will sit and we
/// can verify there's no clipping or overlap with content.
///
/// **Tomorrow** (when an AdMob app/banner unit ID is configured) this same
/// widget will mount a `BannerAd` from `google_mobile_ads` instead. Pages
/// don't need to change — they just keep dropping `BannerAdHost()` into
/// the Scaffold's `bottomNavigationBar` slot (or above an existing nav bar).
class BannerAdHost extends StatelessWidget {
  const BannerAdHost({super.key});

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Ad placeholder',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
              Positioned(
                top: 4,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'Ad',
                    style: TextStyle(
                      fontSize: 9,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
