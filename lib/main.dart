import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/service_locator.dart';
import 'controllers/auth_bloc/auth_bloc.dart';
import 'controllers/product_bloc/product_bloc.dart';
import 'controllers/favourite_bloc/favourite_bloc.dart';
import 'controllers/settings_cubit/settings_cubit.dart';
import 'views/splash/splash_view.dart';
import 'controllers/favourite_bloc/favourite_event.dart';
import 'core/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI for Desktop platforms ONLY.
      // Mobile platforms (Android/iOS) should use the native sqflite factory.
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<ProductBloc>()),
        BlocProvider(create: (_) => getIt<FavouriteBloc>()..add(LoadFavourites())),
      ],
      child: BlocBuilder<SettingsCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Catalog Pro',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            locale: locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashView(),
          );
        },
      ),
    );
  }
}
