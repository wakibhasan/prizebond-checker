import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/cubit/auth_cubit.dart';

void registerAuthModule(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // The AuthCubit is a singleton because it carries app-wide auth state that
  // many widgets read. Feature-local cubits (BondsListCubit, etc.) are
  // registered with `registerFactory` so each page gets a fresh instance.
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));
}
