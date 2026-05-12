import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/faq.dart';
import '../../domain/repositories/faqs_repository.dart';

part 'faqs_state.dart';

class FaqsCubit extends Cubit<FaqsState> {
  final FaqsRepository _repository;

  FaqsCubit(this._repository) : super(const FaqsState());

  Future<void> load() async {
    emit(state.copyWith(status: FaqsStatus.loading, clearError: true));
    final result = await _repository.listFaqs();
    result.fold(
      (f) => emit(state.copyWith(
        status: FaqsStatus.error,
        errorMessage: f.message,
      )),
      (faqs) => emit(state.copyWith(
        status: FaqsStatus.loaded,
        faqs: faqs,
        clearError: true,
      )),
    );
  }
}
