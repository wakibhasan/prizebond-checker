part of 'add_bond_cubit.dart';

enum AddBondSubmitStatus {
  idle,
  submitting,
  success,
  quotaExceeded,
  duplicate,
  error,
}

class AddBondState extends Equatable {
  final AddBondSubmitStatus submitStatus;
  final BondQuota? quotaSnapshot;
  final Bond? addedBond;
  final String? errorMessage;

  const AddBondState({
    this.submitStatus = AddBondSubmitStatus.idle,
    this.quotaSnapshot,
    this.addedBond,
    this.errorMessage,
  });

  AddBondState copyWith({
    AddBondSubmitStatus? submitStatus,
    BondQuota? quotaSnapshot,
    Bond? addedBond,
    String? errorMessage,
    bool clearError = false,
    bool clearQuotaSnapshot = false,
  }) {
    return AddBondState(
      submitStatus: submitStatus ?? this.submitStatus,
      quotaSnapshot:
          clearQuotaSnapshot ? null : (quotaSnapshot ?? this.quotaSnapshot),
      addedBond: addedBond ?? this.addedBond,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [submitStatus, quotaSnapshot, addedBond, errorMessage];
}
