import 'package:get_it/get_it.dart';

import 'data/datasources/faqs_remote_datasource.dart';
import 'data/repositories/faqs_repository_impl.dart';
import 'domain/repositories/faqs_repository.dart';
import 'presentation/cubit/faqs_cubit.dart';

void registerFaqsModule(GetIt sl) {
  sl.registerLazySingleton<FaqsRemoteDataSource>(() => FaqsRemoteDataSource(sl()));
  sl.registerLazySingleton<FaqsRepository>(() => FaqsRepositoryImpl(sl()));
  sl.registerFactory<FaqsCubit>(() => FaqsCubit(sl()));
}
