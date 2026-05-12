import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ads/banner_ad_host.dart';
import '../cubit/auth_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _mobileCtrl = TextEditingController(text: user?.mobile ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  String? _validateMobile(String? raw) {
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

  String? _validateName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'নাম প্রয়োজন।';
    if (raw.trim().length > 120) return 'অনেক বড়।';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await cubit.updateName(_nameCtrl.text.trim());
    await cubit.submitMobile(_mobileCtrl.text.trim());

    if (!mounted) return;
    final state = cubit.state;
    if (state.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isSaving = state.status == AuthStatus.loading;
        return Scaffold(
          appBar: AppBar(title: const Text('Edit profile')),
          bottomNavigationBar: const BannerAdHost(),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobileCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile (01XXXXXXXXX)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: _validateMobile,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: isSaving ? null : _save,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(isSaving ? 'Saving…' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
