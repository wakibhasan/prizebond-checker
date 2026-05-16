import 'package:flutter/material.dart';

/// One shortcut tile in the home page's Quick Actions strip.
class QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Horizontal row of circular icon shortcuts under the home hero card.
///
/// Distributed evenly across the available width; each tile is a small
/// tinted circle with the action's primary-colored icon and a label below.
class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => _Tile(action: a)).toList(),
    );
  }
}

class _Tile extends StatelessWidget {
  final QuickAction action;
  const _Tile({required this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: scheme.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: action.onTap,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  action.icon,
                  color: scheme.onPrimaryContainer,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
