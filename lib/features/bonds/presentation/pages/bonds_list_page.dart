import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/injection_container.dart';
import '../../domain/entities/bond.dart';
import '../../domain/repositories/bonds_repository.dart';
import '../cubit/bonds_list_cubit.dart';
import 'add_bond_page.dart';

class BondsListPage extends StatelessWidget {
  const BondsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BondsListCubit>(
      create: (_) => sl<BondsListCubit>()..load(),
      child: const _BondsListView(),
    );
  }
}

class _BondsListView extends StatelessWidget {
  const _BondsListView();

  Future<void> _openAdd(BuildContext context) async {
    final added = await Navigator.of(context).push<Bond?>(
      MaterialPageRoute(builder: (_) => const AddBondPage()),
    );
    if (added != null && context.mounted) {
      context.read<BondsListCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<BondsListCubit, BondsListState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<BondsListCubit>().load(),
            child: switch (state.status) {
              BondsListStatus.initial ||
              BondsListStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              BondsListStatus.error => _ErrorView(
                  message: state.errorMessage ?? 'Could not load bonds.',
                  onRetry: () => context.read<BondsListCubit>().load(),
                ),
              BondsListStatus.loaded => state.bonds.isEmpty
                  ? const _EmptyView()
                  : _LoadedList(bonds: state.bonds),
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Add bond'),
      ),
    );
  }
}

class _LoadedList extends StatelessWidget {
  final List<Bond> bonds;
  const _LoadedList({required this.bonds});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: bonds.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final b = bonds[i];
        return _BondCard(
          index: i + 1,
          bond: b,
          onDelete: () => _onDelete(context, b),
        );
      },
    );
  }

  Future<void> _onDelete(BuildContext context, Bond b) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<BondsListCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await sl<BondsRepository>().deleteBond(b.id);
    if (!context.mounted) return;
    result.fold(
      (f) {
        messenger.showSnackBar(SnackBar(content: Text(f.message)));
        cubit.load();
      },
      (_) {
        cubit.load();
        messenger.showSnackBar(
          SnackBar(content: Text('Deleted bond ${b.bondNumber}')),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove bond?'),
        content: const Text('আপনি কি এই বন্ডটি মুছতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Rounded card row for one saved bond. Leading numbered avatar, bond
/// number (tabular figures so the digits sit on the same column from row
/// to row), trailing delete icon.
class _BondCard extends StatelessWidget {
  final int index;
  final Bond bond;
  final VoidCallback onDelete;

  const _BondCard({
    required this.index,
    required this.bond,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                '$index',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bond number',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bond.bondNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: 1.1,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: Icon(Icons.delete_outline, color: scheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
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
          Icons.receipt_long_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'কোনো প্রাইজ বন্ড নেই',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'নিচের + বাটনে ট্যাপ করে প্রথম প্রাইজ বন্ড যোগ করুন।',
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
