import 'package:get_it/get_it.dart';

import 'data/datasources/draws_remote_datasource.dart';
import 'data/repositories/draws_repository_impl.dart';
import 'domain/repositories/draws_repository.dart';
import 'presentation/cubit/next_draw_cubit.dart';

void registerDrawsModule(GetIt sl) {
  sl.registerLazySingleton<DrawsRemoteDataSource>(() => DrawsRemoteDataSource(sl()));
  sl.registerLazySingleton<DrawsRepository>(() => DrawsRepositoryImpl(sl()));
  sl.registerFactory<NextDrawCubit>(() => NextDrawCubit(sl()));
}
