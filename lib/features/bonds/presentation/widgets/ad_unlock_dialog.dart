import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/bond_quota.dart';
import '../cubit/bond_quota_cubit.dart';

/// Modal dialog that walks the user through "watch N ads to unlock 1 slot".
/// In dev, each "watch" is a fake countdown plus a call to
/// `/ad-views/dev-grant`. In production, this will be replaced with the
/// real AdMob rewarded-interstitial integration.
///
/// Returns `true` if the user successfully unlocked at least one slot,
/// `false` if they cancelled or failed.
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

class _AdUnlockDialogState extends State<AdUnlockDialog> {
  static const _adDuration = Duration(seconds: 3);

  late int _adsNeeded;
  bool _isWatching = false;
  bool _unlockedAtLeastOne = false;
  String? _error;
  Duration _remaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _adsNeeded = widget.initialQuota.adsNeededForNextSlot;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startWatch() async {
    setState(() {
      _isWatching = true;
      _error = null;
      _remaining = _adDuration;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        _remaining -= const Duration(milliseconds: 100);
        if (_remaining <= Duration.zero) {
          t.cancel();
        }
      });
    });

    await Future<void>.delayed(_adDuration);
    _timer?.cancel();

    final slots = await widget.quotaCubit.watchAd();
    await widget.quotaCubit.refresh();

    if (!mounted) return;

    final newQuota = widget.quotaCubit.state.quota;
    setState(() {
      _isWatching = false;
      _adsNeeded = newQuota?.adsNeededForNextSlot ?? _adsNeeded;
      if (slots > 0) _unlockedAtLeastOne = true;
    });

    // If a slot was just granted, auto-close so the user can re-submit.
    if (slots > 0 && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isWatching
        ? 1 - (_remaining.inMilliseconds / _adDuration.inMilliseconds)
        : null;

    return AlertDialog(
      title: const Text('Unlock more slots'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isWatching
                ? 'Watching ad…'
                : 'Watch $_adsNeeded short ad${_adsNeeded == 1 ? '' : 's'} to add another bond.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_isWatching)
            LinearProgressIndicator(value: progress)
          else
            FilledButton.icon(
              onPressed: _adsNeeded > 0 ? _startWatch : null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch ad'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isWatching
              ? null
              : () => Navigator.of(context).pop(_unlockedAtLeastOne),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
