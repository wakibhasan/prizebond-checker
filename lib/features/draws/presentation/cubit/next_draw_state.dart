part of 'next_draw_cubit.dart';

enum NextDrawStatus { initial, loading, loaded, error }

class NextDrawState extends Equatable {
  final NextDrawStatus status;
  final NextDraw? nextDraw;
  final String? errorMessage;

  const NextDrawState({
    this.status = NextDrawStatus.initial,
    this.nextDraw,
    this.errorMessage,
  });

  NextDrawState copyWith({
    NextDrawStatus? status,
    NextDraw? nextDraw,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NextDrawState(
      status: status ?? this.status,
      nextDraw: nextDraw ?? this.nextDraw,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, nextDraw, errorMessage];
}
