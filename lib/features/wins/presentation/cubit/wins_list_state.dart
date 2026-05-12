part of 'wins_list_cubit.dart';

enum WinsListStatus { initial, loading, loaded, error }

class WinsListState extends Equatable {
  final WinsListStatus status;
  final List<Win> wins;
  final String? errorMessage;

  const WinsListState({
    this.status = WinsListStatus.initial,
    this.wins = const [],
    this.errorMessage,
  });

  WinsListState copyWith({
    WinsListStatus? status,
    List<Win>? wins,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WinsListState(
      status: status ?? this.status,
      wins: wins ?? this.wins,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, wins, errorMessage];
}
