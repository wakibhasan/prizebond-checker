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
    final money = NumberFormat.decimalPattern();
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: wins.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final w = wins[i];
        final scheme = Theme.of(context).colorScheme;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.emoji_events, color: scheme.onPrimaryContainer),
          ),
          title: Text('৳ ${money.format(w.prizeAmount)}'),
          subtitle: Text(
            '${_rankLabel(w.prizeRank)}  •  '
            '${w.bond?.seriesCodeBn ?? '—'} ${w.bond?.bondNumber ?? ''}\n'
            'Draw #${w.draw?.no ?? '—'} on '
            '${w.draw != null ? DateFormat.yMMMd().format(w.draw!.date) : '—'}'
            '  •  Claim by ${DateFormat.yMMMd().format(w.claimWindowEndsAt)}',
          ),
          isThreeLine: true,
        );
      },
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
