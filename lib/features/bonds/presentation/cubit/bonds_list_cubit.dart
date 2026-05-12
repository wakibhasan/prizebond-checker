import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bond.dart';
import '../../domain/repositories/bonds_repository.dart';

part 'bonds_list_state.dart';

class BondsListCubit extends Cubit<BondsListState> {
  final BondsRepository _repository;

  BondsListCubit(this._repository) : super(const BondsListState());

  Future<void> load() async {
    emit(state.copyWith(status: BondsListStatus.loading, clearError: true));
    final result = await _repository.listBonds();
    result.fold(
      (failure) => emit(state.copyWith(
        status: BondsListStatus.error,
        errorMessage: failure.message,
      )),
      (bonds) => emit(state.copyWith(
        status: BondsListStatus.loaded,
        bonds: bonds,
        clearError: true,
      )),
    );
  }
}
