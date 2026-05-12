import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/win.dart';
import '../../domain/repositories/wins_repository.dart';

part 'wins_list_state.dart';

class WinsListCubit extends Cubit<WinsListState> {
  final WinsRepository _repository;

  WinsListCubit(this._repository) : super(const WinsListState());

  Future<void> load() async {
    emit(state.copyWith(status: WinsListStatus.loading, clearError: true));
    final result = await _repository.listWins();
    result.fold(
      (f) => emit(state.copyWith(
        status: WinsListStatus.error,
        errorMessage: f.message,
      )),
      (wins) => emit(state.copyWith(
        status: WinsListStatus.loaded,
        wins: wins,
        clearError: true,
      )),
    );
  }
}
