import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../config/injection_container.dart';
import '../../domain/entities/next_draw.dart';
import '../cubit/next_draw_cubit.dart';

/// Hero card for the home tab. Shows the next anticipated draw and a
/// live D/H/M/S countdown that ticks every second while mounted.
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
        return Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _content(context, state, scheme),
          ),
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
            const LinearProgressIndicator(),
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
              style: TextStyle(color: scheme.error),
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
        Icon(Icons.event_outlined, color: scheme.onPrimaryContainer),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
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
            Icon(Icons.event_outlined, color: scheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(
              draw.drawNo != null ? 'Next draw — #${draw.drawNo}' : 'Next draw',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
            ),
            const Spacer(),
            if (draw.isEstimated)
              Text(
                'estimated',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          dateText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (draw.banglaDateLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            draw.banglaDateLabel!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
          ),
        ],
        const SizedBox(height: 20),
        _Countdown(target: draw.drawDate, scheme: scheme),
      ],
    );
  }
}

/// Stateful countdown that updates every second. Shows four pills:
/// days, hours, minutes, seconds. When the target is in the past it
/// flips to a "Today!" banner.
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
                color: widget.scheme.onPrimaryContainer,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Segment(value: days.toString(), label: 'days', scheme: widget.scheme),
        _Separator(scheme: widget.scheme),
        _Segment(
          value: hours.toString().padLeft(2, '0'),
          label: 'hrs',
          scheme: widget.scheme,
        ),
        _Separator(scheme: widget.scheme),
        _Segment(
          value: minutes.toString().padLeft(2, '0'),
          label: 'min',
          scheme: widget.scheme,
        ),
        _Separator(scheme: widget.scheme),
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
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  final ColorScheme scheme;
  const _Separator({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
