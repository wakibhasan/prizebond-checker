import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/next_draw.dart';
import '../../domain/repositories/draws_repository.dart';

part 'next_draw_state.dart';

class NextDrawCubit extends Cubit<NextDrawState> {
  final DrawsRepository _repository;

  NextDrawCubit(this._repository) : super(const NextDrawState());

  Future<void> load() async {
    emit(state.copyWith(status: NextDrawStatus.loading, clearError: true));
    final result = await _repository.getNextDraw();
    result.fold(
      (f) => emit(state.copyWith(
        status: NextDrawStatus.error,
        errorMessage: f.message,
      )),
      (d) => emit(state.copyWith(
        status: NextDrawStatus.loaded,
        nextDraw: d,
        clearError: true,
      )),
    );
  }
}
