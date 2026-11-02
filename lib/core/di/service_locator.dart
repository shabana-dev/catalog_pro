import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_bloc/auth_bloc.dart';
import '../../controllers/product_bloc/product_bloc.dart';
import '../../controllers/favourite_bloc/favourite_bloc.dart';
import '../../controllers/settings_cubit/settings_cubit.dart';
import '../network/api_service.dart';
import '../storage/secure_storage.dart';
import '../storage/local_database.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => Dio(BaseOptions(baseUrl: 'https://dummyjson.com')));

  // Core & Storage
  getIt.registerLazySingleton(() => SecureStorage(getIt()));
  getIt.registerLazySingleton(() => LocalDatabase());
  getIt.registerLazySingleton(() => ApiService(getIt(), getIt()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(getIt()));
  getIt.registerFactory(() => ProductBloc(getIt()));
  getIt.registerFactory(() => FavouriteBloc());
  getIt.registerFactory(() => SettingsCubit(getIt()));
}
