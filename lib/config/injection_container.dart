import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_interceptor.dart';
import '../core/auth/auth_token_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/network/network_info.dart';
import '../core/theme/theme_cubit.dart';
import '../features/auth/auth_module.dart';
import '../features/bonds/bonds_module.dart';
import '../features/draws/draws_module.dart';
import '../features/faqs/faqs_module.dart';
import '../features/wins/wins_module.dart';
import 'env.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Auth token storage (depends on SharedPreferences)
  sl.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorageImpl(sl()),
  );

  // Dio with auth interceptor
  sl.registerLazySingleton<Dio>(() => _buildDio(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // ThemeCubit is a singleton because the whole app reads from it via
  // BlocBuilder near the top of the widget tree (see main.dart).
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // Features
  registerAuthModule(sl);
  registerBondsModule(sl);
  registerWinsModule(sl);
  registerFaqsModule(sl);
  registerDrawsModule(sl);
}

Dio _buildDio(AuthTokenStorage storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiV1BaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
}
