import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bonds/presentation/cubit/bond_quota_cubit.dart';

/// Stat tile for the user's total wins. Renders **only when the user has
/// at least one win** — a missing card here is intentional, never a
/// "0 wins" display, to keep the home page from feeling like a scoreboard
/// the user is losing.
class TotalWinsCard extends StatelessWidget {
  const TotalWinsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BondQuotaCubit, BondQuotaState>(
      buildWhen: (a, b) => a.quota?.winsCount != b.quota?.winsCount,
      builder: (context, state) {
        final count = state.quota?.winsCount ?? 0;
        if (count <= 0) {
          return const SizedBox.shrink();
        }

        final scheme = Theme.of(context).colorScheme;
        return Card(
          color: scheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: scheme.onTertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wins so far',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onTertiaryContainer,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        count == 1 ? '1 win' : '$count wins',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: scheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
