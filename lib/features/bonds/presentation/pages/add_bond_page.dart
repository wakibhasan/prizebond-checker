import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/injection_container.dart';
import '../../../../core/ads/banner_ad_host.dart';
import '../../domain/entities/bond.dart';
import '../cubit/add_bond_cubit.dart';
import '../cubit/bond_quota_cubit.dart';
import '../widgets/ad_unlock_dialog.dart';

class AddBondPage extends StatelessWidget {
  const AddBondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddBondCubit>(create: (_) => sl<AddBondCubit>()),
        BlocProvider<BondQuotaCubit>(
          create: (_) => sl<BondQuotaCubit>()..refresh(),
        ),
      ],
      child: const _AddBondView(),
    );
  }
}

class _AddBondView extends StatefulWidget {
  const _AddBondView();

  @override
  State<_AddBondView> createState() => _AddBondViewState();
}

class _AddBondViewState extends State<_AddBondView> {
  final _formKey = GlobalKey<FormState>();
  final _bondNumberCtrl = TextEditingController();

  @override
  void dispose() {
    _bondNumberCtrl.dispose();
    super.dispose();
  }

  String? _validateBondNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'প্রাইজ বন্ড নম্বর প্রয়োজন।';
    if (!RegExp(r'^\d{7}$').hasMatch(raw.trim())) {
      return 'অবশ্যই ৭ অঙ্কের হতে হবে।';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddBondCubit>().submit(
          bondNumber: _bondNumberCtrl.text.trim(),
        );
  }

  Future<void> _handleQuotaExceeded(AddBondState state) async {
    final quota = state.quotaSnapshot;
    if (quota == null) return;
    final quotaCubit = context.read<BondQuotaCubit>();
    quotaCubit.setQuota(quota);

    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdUnlockDialog(
        quotaCubit: quotaCubit,
        initialQuota: quota,
      ),
    );

    if (!mounted) return;
    if (unlocked == true) {
      // Slot granted — clear the block and re-submit the same form.
      context.read<AddBondCubit>().clearQuotaBlock();
      _submit();
    } else {
      context.read<AddBondCubit>().clearQuotaBlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add prize bond')),
      bottomNavigationBar: const BannerAdHost(),
      body: BlocConsumer<AddBondCubit, AddBondState>(
        listenWhen: (a, b) => a.submitStatus != b.submitStatus,
        listener: (context, state) {
          switch (state.submitStatus) {
            case AddBondSubmitStatus.success:
              Navigator.of(context).pop<Bond>(state.addedBond);
              break;
            case AddBondSubmitStatus.quotaExceeded:
              _handleQuotaExceeded(state);
              break;
            case AddBondSubmitStatus.duplicate:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ??
                      'এই বন্ড আগেই যোগ করা হয়েছে।'),
                ),
              );
              break;
            case AddBondSubmitStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'কিছু সমস্যা হয়েছে।')),
              );
              break;
            case AddBondSubmitStatus.idle:
            case AddBondSubmitStatus.submitting:
              break;
          }
        },
        builder: (context, state) {
          final isSubmitting = state.submitStatus == AddBondSubmitStatus.submitting;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _bondNumberCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !isSubmitting,
                  maxLength: 7,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Bond number (7 digits)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                    counterText: '',
                  ),
                  validator: _validateBondNumber,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isSubmitting ? null : _submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(isSubmitting ? 'Saving…' : 'Save bond'),
                ),
                const SizedBox(height: 12),
                BlocBuilder<BondQuotaCubit, BondQuotaState>(
                  builder: (context, qstate) {
                    final q = qstate.quota;
                    if (q == null) return const SizedBox.shrink();
                    return Center(
                      child: Text(
                        '${q.currentBonds} / ${q.bondQuota} slots used',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
