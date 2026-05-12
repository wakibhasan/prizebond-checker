import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/injection_container.dart';
import '../../../../core/ads/banner_ad_host.dart';
import '../../domain/entities/faq.dart';
import '../cubit/faqs_cubit.dart';

class FaqsPage extends StatelessWidget {
  const FaqsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FaqsCubit>(
      create: (_) => sl<FaqsCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('FAQs')),
        bottomNavigationBar: const BannerAdHost(),
        body: const _FaqsView(),
      ),
    );
  }
}

class _FaqsView extends StatelessWidget {
  const _FaqsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqsCubit, FaqsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<FaqsCubit>().load(),
          child: switch (state.status) {
            FaqsStatus.initial ||
            FaqsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            FaqsStatus.error => _ErrorView(
                message: state.errorMessage ?? 'Could not load FAQs.',
                onRetry: () => context.read<FaqsCubit>().load(),
              ),
            FaqsStatus.loaded => state.faqs.isEmpty
                ? const _EmptyView()
                : _GroupedList(faqs: state.faqs),
          },
        );
      },
    );
  }
}

class _GroupedList extends StatelessWidget {
  final List<Faq> faqs;
  const _GroupedList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    // Group by category preserving the server's order; null category last.
    final grouped = <String, List<Faq>>{};
    for (final f in faqs) {
      final key = f.category ?? '_other';
      grouped.putIfAbsent(key, () => []).add(f);
    }

    final sections = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final entry = sections[i];
        final label = entry.key == '_other' ? 'Other' : _humanise(entry.key);
        return _CategorySection(
          title: label,
          faqs: entry.value,
        );
      },
    );
  }

  String _humanise(String key) {
    return key
        .split(RegExp('[_-]'))
        .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Faq> faqs;
  const _CategorySection({required this.title, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...faqs.map((f) => ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20),
              childrenPadding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(f.question),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    f.answer,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            )),
        const Divider(height: 1),
      ],
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
          Icons.help_outline,
          size: 80,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'কোনো FAQ পাওয়া যায়নি।',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
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
