part of 'bond_quota_cubit.dart';

enum BondQuotaStatus { initial, loading, loaded, error }

class BondQuotaState extends Equatable {
  final BondQuotaStatus status;
  final BondQuota? quota;
  final String? errorMessage;

  const BondQuotaState({
    this.status = BondQuotaStatus.initial,
    this.quota,
    this.errorMessage,
  });

  BondQuotaState copyWith({
    BondQuotaStatus? status,
    BondQuota? quota,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BondQuotaState(
      status: status ?? this.status,
      quota: quota ?? this.quota,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, quota, errorMessage];
}
