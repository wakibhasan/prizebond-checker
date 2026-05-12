import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bond_quota.dart';
import '../../domain/repositories/bonds_repository.dart';

part 'bond_quota_state.dart';

class BondQuotaCubit extends Cubit<BondQuotaState> {
  final BondsRepository _repository;

  BondQuotaCubit(this._repository) : super(const BondQuotaState());

  Future<void> refresh() async {
    if (state.status != BondQuotaStatus.loading) {
      emit(state.copyWith(status: BondQuotaStatus.loading, clearError: true));
    }
    final result = await _repository.getQuota();
    result.fold(
      (f) => emit(state.copyWith(
        status: BondQuotaStatus.error,
        errorMessage: f.message,
      )),
      (q) => emit(state.copyWith(
        status: BondQuotaStatus.loaded,
        quota: q,
        clearError: true,
      )),
    );
  }

  /// Updates the quota snapshot directly (e.g. after `addBond` returns
  /// 403 with the live quota body, or after a successful add). Avoids an
  /// extra `/me/quota` roundtrip.
  void setQuota(BondQuota quota) {
    emit(state.copyWith(
      status: BondQuotaStatus.loaded,
      quota: quota,
      clearError: true,
    ));
  }

  Future<int> watchAd() async {
    final result = await _repository.watchAdStub();
    return result.fold((_) => 0, (slots) => slots);
  }
}
