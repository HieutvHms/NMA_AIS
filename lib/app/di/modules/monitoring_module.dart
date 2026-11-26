import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/monitoring/data/datasources/map_remote_data_source_impl.dart';
import '../../../features/monitoring/data/datasources/map_remote_datasource.dart';
import '../../../features/monitoring/data/repositories/map_repository_impl.dart';
import '../../../features/monitoring/domain/repositories/map_repository.dart';
import '../../../features/monitoring/domain/usecases/get_all_map_targets_usecase.dart';
import '../../../features/monitoring/domain/usecases/get_map_targets_usecase.dart';
import '../../../features/monitoring/domain/usecases/search_map_target_by_mmsi_usecase.dart';
import '../../../features/monitoring/presentation/cubit/map_monitoring_cubit.dart';

void registerMonitoringModule(GetIt sl) {
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(sl<MapRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetMapTargetsUseCase(sl<MapRepository>()));
  sl.registerLazySingleton(() => GetAllMapTargetsUseCase(sl<MapRepository>()));
  sl.registerLazySingleton(
    () => SearchMapTargetByMmsiUseCase(sl<MapRepository>()),
  );

  sl.registerFactory<MapMonitoringCubit>(
    () => MapMonitoringCubit(
      getMapTargetsUseCase: sl<GetMapTargetsUseCase>(),
      getAllMapTargetsUseCase: sl<GetAllMapTargetsUseCase>(),
      searchMapTargetByMmsiUseCase: sl<SearchMapTargetByMmsiUseCase>(),
    ),
  );
}
