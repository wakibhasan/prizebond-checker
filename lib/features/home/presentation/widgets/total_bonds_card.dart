import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bonds/presentation/cubit/bond_quota_cubit.dart';

/// Reads `BondQuotaCubit` (provided one level up by the home dashboard)
/// and surfaces the user's saved-bond count as a stat tile.
class TotalBondsCard extends StatelessWidget {
  const TotalBondsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: scheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<BondQuotaCubit, BondQuotaState>(
                builder: (context, state) {
                  final count = state.quota?.currentBonds;
                  final isLoaded = state.status == BondQuotaStatus.loaded;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total prize bonds',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoaded ? '$count' : '—',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
