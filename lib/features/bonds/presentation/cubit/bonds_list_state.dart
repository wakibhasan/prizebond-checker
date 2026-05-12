part of 'bonds_list_cubit.dart';

enum BondsListStatus { initial, loading, loaded, error }

class BondsListState extends Equatable {
  final BondsListStatus status;
  final List<Bond> bonds;
  final String? errorMessage;

  const BondsListState({
    this.status = BondsListStatus.initial,
    this.bonds = const [],
    this.errorMessage,
  });

  BondsListState copyWith({
    BondsListStatus? status,
    List<Bond>? bonds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BondsListState(
      status: status ?? this.status,
      bonds: bonds ?? this.bonds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, bonds, errorMessage];
}
