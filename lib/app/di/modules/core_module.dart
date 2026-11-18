import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_refresh_coordinator.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storege.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

Future<void> registerCoreModule(GetIt sl) async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(sl<FlutterSecureStorage>()),
  );

  final localStorage = LocalStorage(
    sl<SharedPreferences>(),
    secureStorage: sl<SecureStorage>(),
  );
  await localStorage.init();
  sl.registerLazySingleton<LocalStorage>(() => localStorage);

  sl.registerLazySingleton<TokenRefreshCoordinator>(
    () => TokenRefreshCoordinator(
      sl<LocalStorage>(),
      onSessionExpired: () {
        if (sl.isRegistered<AuthCubit>()) {
          sl<AuthCubit>().forceLogout(
            reason: 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.',
          );
        }
      },
    ),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      sl<LocalStorage>(),
      refreshCoordinator: sl<TokenRefreshCoordinator>(),
    ),
  );
}
