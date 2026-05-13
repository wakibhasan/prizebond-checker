import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'config/env.dart';
import 'config/injection_container.dart' as di;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/shell/presentation/pages/root_router_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // dotenv must finish loading before DI resolves Env-dependent singletons.
  await dotenv.load(fileName: '.env');
  await di.initDependencies();
  // GoogleSignIn v7 requires a one-shot initialize() before authenticate().
  // serverClientId is the Web OAuth client ID — the audience the backend's
  // GoogleIdTokenVerifier expects. Skip init if blank so dev builds without
  // a configured client ID don't crash on startup.
  if (Env.googleSignInConfigured) {
    await GoogleSignIn.instance.initialize(serverClientId: Env.googleClientId);
  }
  // Register dev phones as AdMob test devices. Test devices receive
  // test-style ads even when the ad unit is a real one, and SSV callbacks
  // still fire — the supported way to develop against real units without
  // risking account suspension. Find new IDs in `flutter run` logs by
  // grepping for `setTestDeviceIds(Arrays.asList(...))`.
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: const ['54C059B86639C9781A7FB98090C12720'],
    ),
  );
  // Opens the AdMob SDK connection. Required before any BannerAd or
  // RewardedInterstitialAd will load. The App ID it reads from
  // AndroidManifest.xml has to be set before this runs.
  await MobileAds.instance.initialize();
  runApp(const PrizeBondCheckerApp());
}

class PrizeBondCheckerApp extends StatelessWidget {
  const PrizeBondCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthCubit and ThemeCubit are app-wide singletons. Mounting them
        // here lets every descendant read them via BlocBuilder/BlocSelector
        // without re-creating the cubits per route.
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..bootstrap(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => di.sl<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const RootRouterPage(),
          );
        },
      ),
    );
  }
}
