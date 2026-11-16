import 'package:get_it/get_it.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/auth/datasources/auth_remote_datasource.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

void registerAuthModule(GetIt sl) {
  // Repository / Datasource
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRemoteDataSource(sl<LocalStorage>()),
  );

  // Cubit
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );
}

