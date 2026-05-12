import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bond.dart';
import '../../domain/entities/bond_quota.dart';
import '../../domain/repositories/bonds_repository.dart';

part 'add_bond_state.dart';

class AddBondCubit extends Cubit<AddBondState> {
  final BondsRepository _repository;

  AddBondCubit(this._repository) : super(const AddBondState());

  Future<void> submit({required String bondNumber}) async {
    emit(state.copyWith(
      submitStatus: AddBondSubmitStatus.submitting,
      clearError: true,
      clearQuotaSnapshot: true,
    ));

    final result = await _repository.addBond(bondNumber: bondNumber);

    result.fold(
      (failure) {
        if (failure is QuotaExceededFailure) {
          emit(state.copyWith(
            submitStatus: AddBondSubmitStatus.quotaExceeded,
            quotaSnapshot: failure.quota,
            errorMessage: failure.message,
          ));
        } else if (failure is DuplicateBondFailure) {
          emit(state.copyWith(
            submitStatus: AddBondSubmitStatus.duplicate,
            errorMessage: failure.message,
          ));
        } else {
          emit(state.copyWith(
            submitStatus: AddBondSubmitStatus.error,
            errorMessage: failure.message,
          ));
        }
      },
      (bond) => emit(state.copyWith(
        submitStatus: AddBondSubmitStatus.success,
        addedBond: bond,
        clearError: true,
      )),
    );
  }

  /// After a successful ad-watch unlock, reset the submit status so the
  /// page can be re-submitted with the same form values.
  void clearQuotaBlock() {
    emit(state.copyWith(
      submitStatus: AddBondSubmitStatus.idle,
      clearError: true,
      clearQuotaSnapshot: true,
    ));
  }
}
