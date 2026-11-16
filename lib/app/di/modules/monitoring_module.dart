import 'package:get_it/get_it.dart';
import '../../../features/monitoring/cubit/monitoring_cubit.dart';
import '../../../features/monitoring/cubit/route_cubit.dart';
import '../../../features/monitoring/data/repositories/monitoring_repository.dart';

void registerMonitoringModule(GetIt sl) {
  // Repository
  sl.registerLazySingleton<MonitoringRepository>(() => MonitoringRepository());

  // Cubits
  sl.registerFactory<MonitoringCubit>(
    () => MonitoringCubit(sl<MonitoringRepository>()),
  );
  sl.registerFactory<RouteCubit>(() => RouteCubit());
}

