import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';

/// Shown right after sign-in when `user.mobile` is null. Forces the user
/// to enter a Bangladesh mobile number before they can use the app.
/// Cannot be dismissed — back-press exits the app via SystemNavigator.pop.
class MobilePromptPage extends StatefulWidget {
  const MobilePromptPage({super.key});

  @override
  State<MobilePromptPage> createState() => _MobilePromptPageState();
}

class _MobilePromptPageState extends State<MobilePromptPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'মোবাইল নম্বর প্রয়োজন।';
    }
    final cleaned = raw.replaceAll(RegExp(r'[\s\-]'), '');
    final normalized = cleaned.replaceFirst(RegExp(r'^(\+?880)'), '0');
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(normalized)) {
      return 'সঠিক বাংলাদেশী ১১-অঙ্কের মোবাইল নম্বর লিখুন।';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().submitMobile(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Block back-press: leaving here without saving a mobile means
          // the user can't use the app, so we exit instead of dropping
          // them on a blank stack.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Mobile number')),
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.loading;
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'এক ধাপ বাকি',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'আপনি যদি জিতেন, আমরা এই নম্বরে নোটিফিকেশন পাঠাব।',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Mobile (01XXXXXXXXX)',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validate,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (state.errorMessage != null &&
                          state.status != AuthStatus.loading) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
