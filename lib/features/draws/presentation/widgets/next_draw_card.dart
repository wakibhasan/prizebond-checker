import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../config/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/next_draw.dart';
import '../cubit/next_draw_cubit.dart';

/// Hero card for the home tab. Shows the next anticipated draw and a
/// live D/H/M/S countdown that ticks every second while mounted.
///
/// Rendered as a deep-primary gradient panel so it reads as the page's
/// focal point — the rest of the home tab uses lighter surface cards.
class NextDrawCard extends StatelessWidget {
  const NextDrawCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NextDrawCubit>(
      create: (_) => sl<NextDrawCubit>()..load(),
      child: const _NextDrawCardView(),
    );
  }
}

class _NextDrawCardView extends StatelessWidget {
  const _NextDrawCardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NextDrawCubit, NextDrawState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, 0.18) ?? scheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: _content(context, state, scheme),
        );
      },
    );
  }

  Widget _content(BuildContext context, NextDrawState state, ColorScheme scheme) {
    switch (state.status) {
      case NextDrawStatus.initial:
      case NextDrawStatus.loading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(context, scheme, 'Next draw'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: scheme.onPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
            ),
          ],
        );

      case NextDrawStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(context, scheme, 'Next draw'),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Could not load next draw.',
              style: TextStyle(color: scheme.onPrimary),
            ),
          ],
        );

      case NextDrawStatus.loaded:
        return _LoadedContent(draw: state.nextDraw!, scheme: scheme);
    }
  }

  Widget _heading(BuildContext context, ColorScheme scheme, String label) {
    return Row(
      children: [
        Icon(Icons.event_outlined, color: scheme.onPrimary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onPrimary,
              ),
        ),
      ],
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final NextDraw draw;
  final ColorScheme scheme;
  const _LoadedContent({required this.draw, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMMd().format(draw.drawDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.event_outlined, color: scheme.onPrimary, size: 18),
            const SizedBox(width: 8),
            Text(
              draw.drawNo != null ? 'Next draw — #${draw.drawNo}' : 'Next draw',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                  ),
            ),
            const Spacer(),
            if (draw.isEstimated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'estimated',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          dateText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (draw.banglaDateLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            draw.banglaDateLabel!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
        ],
        const SizedBox(height: 20),
        _Countdown(target: draw.drawDate, scheme: scheme),
      ],
    );
  }
}

/// Stateful countdown that updates every second. Each unit (days, hours,
/// minutes, seconds) is its own pill so the rhythm reads as a digital clock.
class _Countdown extends StatefulWidget {
  final DateTime target;
  final ColorScheme scheme;
  const _Countdown({required this.target, required this.scheme});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _computeRemaining());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _computeRemaining() {
    // Treat the draw_date as midday local time so the countdown lands
    // sensibly (the draws happen during business hours).
    final dt = DateTime(
      widget.target.year,
      widget.target.month,
      widget.target.day,
      12,
    );
    return dt.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Center(
        child: Text(
          'Today!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: widget.scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Segment(value: days.toString(), label: 'days', scheme: widget.scheme),
        _Segment(
          value: hours.toString().padLeft(2, '0'),
          label: 'hrs',
          scheme: widget.scheme,
        ),
        _Segment(
          value: minutes.toString().padLeft(2, '0'),
          label: 'min',
          scheme: widget.scheme,
        ),
        _Segment(
          value: seconds.toString().padLeft(2, '0'),
          label: 'sec',
          scheme: widget.scheme,
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String value;
  final String label;
  final ColorScheme scheme;
  const _Segment({required this.value, required this.label, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}
