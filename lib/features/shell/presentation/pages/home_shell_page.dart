import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/injection_container.dart';
import '../../../../core/ads/banner_ad_host.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/floating_bottom_nav.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/edit_profile_page.dart';
import '../../../bonds/presentation/cubit/bond_quota_cubit.dart';
import '../../../bonds/presentation/pages/add_bond_page.dart';
import '../../../bonds/presentation/pages/bonds_list_page.dart';
import '../../../draws/presentation/widgets/next_draw_card.dart';
import '../../../faqs/presentation/pages/faqs_page.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../../../home/presentation/widgets/quick_actions_row.dart';
import '../../../home/presentation/widgets/prize_pool_teaser_card.dart';
import '../../../home/presentation/widgets/total_bonds_card.dart';
import '../../../home/presentation/widgets/total_wins_card.dart';
import '../../../wins/presentation/pages/wins_list_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  void _switchTo(int tab) {
    if (tab < 0 || tab > 3) return;
    setState(() => _index = tab);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = const [
      FloatingNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
      ),
      FloatingNavItem(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        label: 'Bonds',
      ),
      FloatingNavItem(
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
        label: 'Wins',
      ),
      FloatingNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    final bodies = <Widget>[
      _HomeTab(onSwitchTab: _switchTo),
      const _SectionScaffold(title: 'My Bonds', body: BondsListPage()),
      const _SectionScaffold(title: 'My Wins', body: WinsListPage()),
      const _SectionScaffold(title: 'Profile', body: _ProfileTab()),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: bodies[_index]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdHost(),
          FloatingBottomNav(
            items: navItems,
            currentIndex: _index,
            onTap: _switchTo,
          ),
        ],
      ),
    );
  }
}

/// Thin scaffold wrapper for non-home tabs: shows the section title in a
/// consistent place (above the body, no AppBar bar) and lets the inner
/// page focus on its content. Keeps visual rhythm consistent across tabs.
class _SectionScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const _SectionScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const _HomeTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BondQuotaCubit>(
      create: (_) => sl<BondQuotaCubit>()..refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const HomeHeader(),
          const SizedBox(height: 24),
          const NextDrawCard(),
          const SizedBox(height: 20),
          QuickActionsRow(
            actions: [
              QuickAction(
                icon: Icons.add,
                label: 'Add Bond',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBondPage()),
                ),
              ),
              QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'My Bonds',
                onTap: () => onSwitchTab(1),
              ),
              QuickAction(
                icon: Icons.emoji_events_outlined,
                label: 'My Wins',
                onTap: () => onSwitchTab(2),
              ),
              QuickAction(
                icon: Icons.help_outline,
                label: 'FAQs',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const TotalBondsCard(),
          const SizedBox(height: 12),
          const TotalWinsCard(),
          const SizedBox(height: 12),
          const PrizePoolTeaserCard(),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _InfoCard(
              tiles: [
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: user?.name ?? '—',
                ),
                _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '—',
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Mobile',
                  value: user?.mobile ?? '—',
                ),
                _InfoTile(
                  icon: Icons.bookmark_outline,
                  label: 'Bond quota',
                  value: '${user?.bondQuota ?? '—'} slots',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionsCard(
              tiles: [
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit profile',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),
                const _ThemeActionTile(),
                _ActionTile(
                  icon: Icons.help_outline,
                  label: 'FAQs',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FaqsPage()),
                  ),
                ),
                _ActionTile(
                  icon: Icons.logout,
                  label: 'Sign out',
                  destructive: true,
                  onTap: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoTile> tiles;
  const _InfoCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              tiles[i],
              if (i < tiles.length - 1) const Divider(indent: 56, endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final List<Widget> tiles;
  const _ActionsCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: tiles),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : scheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: destructive ? scheme.error : scheme.primary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
      onTap: onTap,
    );
  }
}

class _ThemeActionTile extends StatelessWidget {
  const _ThemeActionTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final scheme = Theme.of(context).colorScheme;
        return ListTile(
          leading: Icon(_iconFor(mode), color: scheme.primary),
          title: Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(_labelFor(mode)),
          trailing: Icon(Icons.chevron_right, color: scheme.outline),
          onTap: () => _openChooser(context),
        );
      },
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  String _labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  Future<void> _openChooser(BuildContext context) async {
    final cubit = context.read<ThemeCubit>();
    final current = cubit.state;

    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (m) {
            if (m != null) Navigator.of(sheetCtx).pop(m);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Theme',
                style: Theme.of(sheetCtx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final option in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: option,
                  title: Text(_labelFor(option)),
                  secondary: Icon(_iconFor(option)),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      await cubit.setMode(picked);
    }
  }
}
