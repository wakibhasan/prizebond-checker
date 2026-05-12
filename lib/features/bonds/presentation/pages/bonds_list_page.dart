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
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: bonds.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = bonds[i];
        return Dismissible(
          key: ValueKey('bond-${b.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => _onDeleted(context, b),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            title: Text(
              b.bondNumber,
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: 1.2,
                fontSize: 18,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                final confirmed = await _confirmDelete(context);
                if (confirmed == true && context.mounted) {
                  _onDeleted(context, b);
                }
              },
            ),
          ),
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

  void _onDeleted(BuildContext context, Bond b) async {
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
