import 'package:get_it/get_it.dart';

import 'data/datasources/bonds_remote_datasource.dart';
import 'data/repositories/bonds_repository_impl.dart';
import 'domain/repositories/bonds_repository.dart';
import 'presentation/cubit/add_bond_cubit.dart';
import 'presentation/cubit/bond_quota_cubit.dart';
import 'presentation/cubit/bonds_list_cubit.dart';

void registerBondsModule(GetIt sl) {
  sl.registerLazySingleton<BondsRemoteDataSource>(() => BondsRemoteDataSource(sl()));
  sl.registerLazySingleton<BondsRepository>(() => BondsRepositoryImpl(sl()));

  // Per-page cubits — each page gets a fresh instance.
  sl.registerFactory<BondsListCubit>(() => BondsListCubit(sl()));
  sl.registerFactory<AddBondCubit>(() => AddBondCubit(sl()));
  sl.registerFactory<BondQuotaCubit>(() => BondQuotaCubit(sl()));
}
