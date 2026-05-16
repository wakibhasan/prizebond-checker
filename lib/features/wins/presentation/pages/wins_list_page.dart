import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../../../config/injection_container.dart';
import '../../domain/entities/win.dart';
import '../cubit/wins_list_cubit.dart';

class WinsListPage extends StatelessWidget {
  const WinsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WinsListCubit>(
      create: (_) => sl<WinsListCubit>()..load(),
      child: const _WinsListView(),
    );
  }
}

class _WinsListView extends StatelessWidget {
  const _WinsListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WinsListCubit, WinsListState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<WinsListCubit>().load(),
          child: switch (state.status) {
            WinsListStatus.initial ||
            WinsListStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            WinsListStatus.error => _ErrorView(
                message: state.errorMessage ?? 'Could not load wins.',
                onRetry: () => context.read<WinsListCubit>().load(),
              ),
            WinsListStatus.loaded => state.wins.isEmpty
                ? const _EmptyView()
                : _LoadedList(wins: state.wins),
          },
        );
      },
    );
  }
}

class _LoadedList extends StatelessWidget {
  final List<Win> wins;
  const _LoadedList({required this.wins});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: wins.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _WinCard(win: wins[i]),
    );
  }
}

/// Rounded card for one win. Trophy avatar, prize amount as the title,
/// rank pill, then a small two-line breakdown of bond/draw/claim window.
class _WinCard extends StatelessWidget {
  final Win win;
  const _WinCard({required this.win});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.decimalPattern();
    final claimBy = DateFormat.yMMMd().format(win.claimWindowEndsAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.tertiaryContainer,
              child: Icon(
                Icons.emoji_events,
                color: scheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '৳ ${money.format(win.prizeAmount)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ),
                      _RankPill(rank: win.prizeRank),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${win.bond?.seriesCodeBn ?? '—'} '
                    '${win.bond?.bondNumber ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Draw #${win.draw?.no ?? '—'} on '
                    '${win.draw != null ? DateFormat.yMMMd().format(win.draw!.date) : '—'}  •  '
                    'Claim by $claimBy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final int rank;
  const _RankPill({required this.rank});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _rankLabel(rank),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _rankLabel(int rank) {
    switch (rank) {
      case 1:
        return '1st prize';
      case 2:
        return '2nd prize';
      case 3:
        return '3rd prize';
      default:
        return '${rank}th prize';
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.emoji_events_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'এখনও কোনো পুরস্কার নেই',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'আপনার বন্ড জিতলে এখানে দেখানো হবে।',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
