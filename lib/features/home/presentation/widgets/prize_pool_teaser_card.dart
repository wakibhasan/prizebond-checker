import 'package:flutter/material.dart';

/// Shows the BB prize structure each draw — ranks 1 through 5 with their
/// amounts. Static and aspirational; no per-user data, never empty.
class PrizePoolTeaserCard extends StatelessWidget {
  const PrizePoolTeaserCard({super.key});

  // Per the BB 100-Tk scheme (unchanged since 1996). Counts are per series.
  static const _prizes = <_PrizeTier>[
    _PrizeTier(rank: '1st prize', amountBdt: 600000, count: 1),
    _PrizeTier(rank: '2nd prize', amountBdt: 325000, count: 1),
    _PrizeTier(rank: '3rd prize', amountBdt: 100000, count: 2),
    _PrizeTier(rank: '4th prize', amountBdt: 50000, count: 2),
    _PrizeTier(rank: '5th prize', amountBdt: 10000, count: 40),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Prizes per draw',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'প্রতিটি ড্রতে যে পুরস্কারগুলো জেতা যায়',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ..._prizes.map((p) => _PrizeRow(tier: p)),
          ],
        ),
      ),
    );
  }
}

class _PrizeTier {
  final String rank;
  final int amountBdt;
  final int count;
  const _PrizeTier({
    required this.rank,
    required this.amountBdt,
    required this.count,
  });
}

class _PrizeRow extends StatelessWidget {
  final _PrizeTier tier;
  const _PrizeRow({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              tier.rank,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              '৳ ${_formatBdt(tier.amountBdt)}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              '×${tier.count}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats an integer BDT amount with Indian-style grouping (lakh, crore):
  /// 600000 → "6,00,000".
  static String _formatBdt(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    var current = rest;
    while (current.length > 2) {
      groups.insert(0, current.substring(current.length - 2));
      current = current.substring(0, current.length - 2);
    }
    if (current.isNotEmpty) groups.insert(0, current);
    return '${groups.join(',')},$last3';
  }
}
