import 'package:get_it/get_it.dart';
import '../../../features/ais_config/cubit/ais_config_cubit.dart';
import '../../../features/ais_config/data/repositories/ais_config_repository.dart';

void registerAisConfigModule(GetIt sl) {
  // Repository
  sl.registerLazySingleton<AisConfigRepository>(() => AisConfigRepository());

  // Cubit
  sl.registerFactory<AisConfigCubit>(
    () => AisConfigCubit(sl<AisConfigRepository>()),
  );
}

