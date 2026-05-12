import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/injection_container.dart';
import '../../../../core/ads/banner_ad_host.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/edit_profile_page.dart';
import '../../../bonds/presentation/cubit/bond_quota_cubit.dart';
import '../../../bonds/presentation/pages/bonds_list_page.dart';
import '../../../draws/presentation/widgets/next_draw_card.dart';
import '../../../faqs/presentation/pages/faqs_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final tabs = <_Tab>[
      _Tab(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        body: const _HomeTab(),
      ),
      _Tab(
        label: 'Bonds',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        body: const BondsListPage(),
      ),
      _Tab(
        label: 'Wins',
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
        body: const WinsListPage(),
      ),
      _Tab(
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        body: const _ProfileTab(),
      ),
    ];

    return Scaffold(
      appBar: _buildAppBar(context, tabs[_index].label),
      body: tabs[_index].body,
      bottomNavigationBar: Column(
        // Stack the banner above the NavigationBar so it's persistent on
        // every tab without each tab body needing its own slot.
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdHost(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: tabs
                .map((t) => NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.selectedIcon),
                      label: t.label,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Home tab gets a personalised greeting in the app bar
  /// (`স্বাগতম, [name]`). Other tabs show their tab label.
  PreferredSizeWidget _buildAppBar(BuildContext context, String fallbackLabel) {
    if (_index != 0) {
      return AppBar(title: Text(fallbackLabel));
    }
    return AppBar(
      title: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (a, b) => a.user?.name != b.user?.name,
        builder: (context, state) {
          final name = state.user?.name;
          if (name == null || name.isEmpty) {
            return const Text('স্বাগতম');
          }
          return RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  Theme.of(context).textTheme.titleLarge,
              children: [
                const TextSpan(
                  text: 'স্বাগতম, ',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
  const _Tab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.body,
  });
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    // The greeting + user name live in the AppBar — see _buildAppBar in
    // _HomeShellPageState. The body is the dashboard: next draw, total
    // bonds, and the prize-pool teaser. BondQuotaCubit is provided here
    // so TotalBondsCard (and any future quota-aware tile) can read it.
    return BlocProvider<BondQuotaCubit>(
      create: (_) => sl<BondQuotaCubit>()..refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NextDrawCard(),
          SizedBox(height: 12),
          TotalBondsCard(),
          // TotalWinsCard renders SizedBox.shrink() when winsCount == 0,
          // so nothing appears on the dashboard until the user actually
          // has a win — no "0 wins" tile to upset anyone.
          SizedBox(height: 12),
          TotalWinsCard(),
          SizedBox(height: 12),
          PrizePoolTeaserCard(),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(user?.name ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Mobile'),
              subtitle: Text(user?.mobile ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Bond quota'),
              subtitle: Text('${user?.bondQuota ?? '—'} slots'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit profile'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            const _ThemeTile(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQs'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FaqsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return ListTile(
          leading: Icon(_iconFor(mode)),
          title: const Text('Theme'),
          subtitle: Text(_labelFor(mode)),
          trailing: const Icon(Icons.chevron_right),
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
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
