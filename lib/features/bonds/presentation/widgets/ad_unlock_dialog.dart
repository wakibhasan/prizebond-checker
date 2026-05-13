import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../config/env.dart';
import '../../../../config/injection_container.dart';
import '../../../../core/ads/ad_unit_ids.dart';
import '../../domain/entities/bond_quota.dart';
import '../../domain/repositories/bonds_repository.dart';
import '../cubit/bond_quota_cubit.dart';

/// Real rewarded-interstitial unlock flow.
///
/// Slots are *not* granted by this widget. The user watches an ad, AdMob's
/// servers POST to our backend's SSV endpoint, and the backend bumps
/// `bond_quota` if the user has hit their 2-ads-per-slot mark. This dialog
/// just orchestrates the show + then polls `GET /me/quota` for evidence
/// the postback landed.
///
/// Returns `true` once a slot has been granted, `false` if the user cancels.
class AdUnlockDialog extends StatefulWidget {
  final BondQuotaCubit quotaCubit;
  final BondQuota initialQuota;

  const AdUnlockDialog({
    super.key,
    required this.quotaCubit,
    required this.initialQuota,
  });

  @override
  State<AdUnlockDialog> createState() => _AdUnlockDialogState();
}

enum _Phase { idle, preparing, loading, showing, verifying, devGranting }

class _AdUnlockDialogState extends State<AdUnlockDialog> {
  late final BondsRepository _bondsRepo;
  late BondQuota _quota;
  _Phase _phase = _Phase.idle;
  String? _error;
  bool _unlockedAtLeastOne = false;
  RewardedInterstitialAd? _ad;

  @override
  void initState() {
    super.initState();
    _bondsRepo = sl<BondsRepository>();
    _quota = widget.initialQuota;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _watchAd() async {
    setState(() {
      _phase = _Phase.preparing;
      _error = null;
    });

    // 1. Register the ad-view intent. The backend mints an ad_views row
    //    and returns SSV identifiers the ad has to echo back.
    final intentResult = await _bondsRepo.registerAdView(
      adUnitId: AdUnitIds.rewardedInterstitial,
    );
    final intent = intentResult.fold((_) => null, (i) => i);
    if (intent == null) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = intentResult.fold(
          (f) => f.message,
          (_) => 'Could not register ad view.',
        );
      });
      return;
    }

    if (!mounted) return;
    setState(() => _phase = _Phase.loading);

    // 2. Load the rewarded interstitial.
    final adCompleter = Completer<RewardedInterstitialAd?>();
    RewardedInterstitialAd.load(
      adUnitId: AdUnitIds.rewardedInterstitial,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: adCompleter.complete,
        onAdFailedToLoad: (err) {
          debugPrint('RewardedInterstitial load failed: $err');
          adCompleter.complete(null);
        },
      ),
    );
    final ad = await adCompleter.future;
    if (!mounted) {
      ad?.dispose();
      return;
    }
    if (ad == null) {
      setState(() {
        _phase = _Phase.idle;
        _error = 'Could not load ad. Try again in a moment.';
      });
      return;
    }

    // 3. Attach SSV identifiers + lifecycle callbacks, then show.
    _ad = ad;
    ad.setServerSideOptions(ServerSideVerificationOptions(
      userId: intent.ssvUserId,
      customData: intent.ssvCustomData,
    ));
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (closedAd) {
        closedAd.dispose();
        _ad = null;
        _pollForVerification();
      },
      onAdFailedToShowFullScreenContent: (failedAd, err) {
        debugPrint('RewardedInterstitial show failed: $err');
        failedAd.dispose();
        _ad = null;
        if (!mounted) return;
        setState(() {
          _phase = _Phase.idle;
          _error = 'The ad could not be shown.';
        });
      },
    );

    setState(() => _phase = _Phase.showing);
    ad.show(onUserEarnedReward: (_, _) {
      // Intentionally empty. The phone is not authorised to grant slots —
      // the backend does that when AdMob's signed SSV postback arrives.
    });
  }

  /// Dev-only fallback: skip AdMob entirely and credit one ad-watch via
  /// `/ad-views/dev-grant`. Used while the AdMob account is pending
  /// approval — exercises the slot-grant pipeline without needing a real
  /// or test ad to load. Gated behind `Env.devLoginEnabled` so it never
  /// ships to production users.
  Future<void> _devGrant() async {
    setState(() {
      _phase = _Phase.devGranting;
      _error = null;
    });

    final result = await _bondsRepo.grantDevSlot();
    if (!mounted) return;

    final snapshot = _quota;
    await widget.quotaCubit.refresh();
    if (!mounted) return;

    final fresh = widget.quotaCubit.state.quota ?? snapshot;
    setState(() => _quota = fresh);

    final slotsGranted = result.fold((_) => 0, (s) => s);
    if (slotsGranted > 0 || fresh.bondQuota > snapshot.bondQuota) {
      _unlockedAtLeastOne = true;
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _phase = _Phase.idle;
      _error = result.fold((f) => f.message, (_) => null);
    });
  }

  /// After the user closes the ad, poll `/me/quota` for evidence that
  /// AdMob's SSV postback has landed. Times out after ~10s.
  Future<void> _pollForVerification() async {
    if (!mounted) return;
    setState(() => _phase = _Phase.verifying);

    final snapshot = _quota;
    for (int i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      await widget.quotaCubit.refresh();
      final fresh = widget.quotaCubit.state.quota;
      if (fresh == null || fresh == snapshot) continue;

      setState(() => _quota = fresh);

      if (fresh.bondQuota > snapshot.bondQuota) {
        _unlockedAtLeastOne = true;
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      // Progress without a new slot (1 of 2 ads watched). Reset to idle so
      // the user can watch the next one.
      setState(() => _phase = _Phase.idle);
      return;
    }

    if (!mounted) return;
    setState(() {
      _phase = _Phase.idle;
      _error = 'Reward not received yet — the network may be slow. Try again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final adsLeft = _quota.adsNeededForNextSlot;
    final phase = _phase;
    final isWorking = phase != _Phase.idle;

    return AlertDialog(
      title: const Text('Unlock more slots'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _statusText(phase, adsLeft),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (isWorking)
            const LinearProgressIndicator()
          else ...[
            FilledButton.icon(
              onPressed: adsLeft > 0 ? _watchAd : null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch ad'),
            ),
            if (Env.devLoginEnabled) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _devGrant,
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('DEV: Grant slot'),
              ),
            ],
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isWorking
              ? null
              : () => Navigator.of(context).pop(_unlockedAtLeastOne),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _statusText(_Phase phase, int adsLeft) {
    switch (phase) {
      case _Phase.preparing:
        return 'Preparing ad…';
      case _Phase.loading:
        return 'Loading ad…';
      case _Phase.showing:
        return 'Showing ad…';
      case _Phase.verifying:
        return 'Verifying reward…';
      case _Phase.devGranting:
        return 'Granting dev slot…';
      case _Phase.idle:
        return 'Watch $adsLeft short ad${adsLeft == 1 ? '' : 's'} to add another bond.';
    }
  }
}
