import 'package:get_it/get_it.dart';

import 'data/datasources/wins_remote_datasource.dart';
import 'data/repositories/wins_repository_impl.dart';
import 'domain/repositories/wins_repository.dart';
import 'presentation/cubit/wins_list_cubit.dart';

void registerWinsModule(GetIt sl) {
  sl.registerLazySingleton<WinsRemoteDataSource>(() => WinsRemoteDataSource(sl()));
  sl.registerLazySingleton<WinsRepository>(() => WinsRepositoryImpl(sl()));
  sl.registerFactory<WinsListCubit>(() => WinsListCubit(sl()));
}
