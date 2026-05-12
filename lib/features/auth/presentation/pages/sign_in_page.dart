import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../config/env.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'প্রাইজ বন্ড সংরক্ষণ করুন,\nজিতলে আমরা জানিয়ে দেব।',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(flex: 3),
                  if (state.status == AuthStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    FilledButton.icon(
                      // Disabled when no Web client ID is configured —
                      // without one, GoogleSignIn would mint a token whose
                      // `aud` claim the backend rejects.
                      onPressed: Env.googleSignInConfigured
                          ? () => _signInWithGoogle(context)
                          : null,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Sign in with Google'),
                    ),
                    if (!Env.googleSignInConfigured) ...[
                      const SizedBox(height: 8),
                      Text(
                        '(Google sign-in arrives once OAuth credentials are configured.)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (Env.devLoginEnabled) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Developer',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showDevLoginSheet(context),
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('Continue without Google'),
                      ),
                    ],
                  ],
                  if (state.status == AuthStatus.error &&
                      state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    try {
      // v7: authenticate() throws on cancel/error and returns the account on
      // success. The ID token is read synchronously off `.authentication`.
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        cubit.reportSignInError('Google did not return an ID token.');
        return;
      }
      await cubit.googleSignIn(idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      cubit.reportSignInError(e.description ?? 'Google sign-in failed.');
    } catch (_) {
      cubit.reportSignInError('Google sign-in failed. Please try again.');
    }
  }

  void _showDevLoginSheet(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final emailCtrl = TextEditingController(text: 'dev@example.com');
    final nameCtrl = TextEditingController(text: 'Dev User');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dev login',
              style: Theme.of(sheetCtx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                cubit.devSignIn(
                  email: emailCtrl.text.trim(),
                  name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
