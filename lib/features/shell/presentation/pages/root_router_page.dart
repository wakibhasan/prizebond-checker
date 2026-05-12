import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/mobile_prompt_page.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import 'home_shell_page.dart';

/// Single source of truth for top-level navigation. Watches AuthCubit and
/// swaps the root widget based on auth state, so we never end up with two
/// pages making conflicting routing decisions.
class RootRouterPage extends StatelessWidget {
  const RootRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (state.status) {
            AuthStatus.initial ||
            AuthStatus.loading =>
              const _LoadingScreen(key: ValueKey('loading')),
            AuthStatus.unauthenticated ||
            AuthStatus.error =>
              const SignInPage(key: ValueKey('sign-in')),
            AuthStatus.needsMobile =>
              const MobilePromptPage(key: ValueKey('mobile-prompt')),
            AuthStatus.authenticated =>
              const HomeShellPage(key: ValueKey('home-shell')),
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
