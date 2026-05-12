part of 'faqs_cubit.dart';

enum FaqsStatus { initial, loading, loaded, error }

class FaqsState extends Equatable {
  final FaqsStatus status;
  final List<Faq> faqs;
  final String? errorMessage;

  const FaqsState({
    this.status = FaqsStatus.initial,
    this.faqs = const [],
    this.errorMessage,
  });

  FaqsState copyWith({
    FaqsStatus? status,
    List<Faq>? faqs,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FaqsState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, faqs, errorMessage];
}
