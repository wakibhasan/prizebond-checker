import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Greeting strip at the top of the home tab.
///
/// Mirrors the pattern used in modern dashboard apps: circular avatar
/// (initials, no real image yet), one-line "Hi, [first name]" + a
/// time-of-day greeting under it, and a notification bell on the right.
/// The bell is a visual placeholder for now — wired to nothing.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a.user?.name != b.user?.name,
      builder: (context, state) {
        final name = state.user?.name;
        final firstName = (name == null || name.trim().isEmpty)
            ? null
            : name.trim().split(RegExp(r'\s+')).first;
        return Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                _initials(name),
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName != null ? 'Hi, $firstName' : 'স্বাগতম',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _timeOfDayGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            _BellButton(scheme: scheme),
          ],
        );
      },
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _timeOfDayGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning!';
    if (h < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }
}

class _BellButton extends StatelessWidget {
  final ColorScheme scheme;
  const _BellButton({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          // Notifications surface — TBD.
        },
        icon: Icon(
          Icons.notifications_outlined,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
