import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/device/data/datasources/device_remote_data_source_impl.dart';
import '../../../features/device/data/datasources/device_remote_datasource.dart';
import '../../../features/device/data/repositories/device_repository_impl.dart';
import '../../../features/device/domain/repositories/device_repository.dart';
import '../../../features/device/domain/usecases/get_devices_usecase.dart';
import '../../../features/device/presentation/device_config/cubit/device_config_cubit.dart';
import '../../../features/device/presentation/device_list/cubit/device_list_cubit.dart';

void registerDeviceModule(GetIt sl) {
  // DataSource
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(sl<DioClient>().dio),
  );

  // Repository
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(sl<DeviceRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetDevicesUseCase(sl<DeviceRepository>()));

  // Cubits
  sl.registerFactory<DeviceListCubit>(
    () => DeviceListCubit(getDevicesUseCase: sl<GetDevicesUseCase>()),
  );
  sl.registerFactory<DeviceConfigCubit>(() => DeviceConfigCubit());
}
