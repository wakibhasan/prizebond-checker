import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One destination in the floating pill bottom nav.
class FloatingNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Pill-shaped floating bottom navigation bar.
///
/// Rendered as a solid primary-colored pill with white icons. The active
/// item is highlighted with a circular white background and an inverted
/// icon color. Sits inside the `bottomNavigationBar` slot above the
/// `BannerAdHost` so it doesn't overlap content.
class FloatingBottomNav extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: item.label,
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? scheme.onPrimary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              selected ? item.selectedIcon : item.icon,
              color: selected ? scheme.primary : scheme.onPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
