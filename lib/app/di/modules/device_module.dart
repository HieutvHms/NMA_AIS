import 'package:get_it/get_it.dart';
import '../../../features/device/presentation/cubit/device_config_cubit.dart';
import '../../../features/device/presentation/cubit/device_list_cubit.dart';
import '../../../features/device/data/datasources/device_remote_datasource.dart';
import '../../../features/device/data/repositories/device_repository_impl.dart';
import '../../../features/device/domain/repositories/device_repository.dart';
import '../../../features/device/domain/usecases/create_device_usecase.dart';
import '../../../features/device/domain/usecases/delete_device_usecase.dart';
import '../../../features/device/domain/usecases/get_device_detail_usecase.dart';
import '../../../features/device/domain/usecases/get_devices_usecase.dart';
import '../../../features/device/domain/usecases/update_device_usecase.dart';

void registerDeviceModule(GetIt sl) {
  // DataSource
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(sl<DeviceRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetDevicesUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton(() => GetDeviceDetailUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton(() => CreateDeviceUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton(() => UpdateDeviceUseCase(sl<DeviceRepository>()));
  sl.registerLazySingleton(() => DeleteDeviceUseCase(sl<DeviceRepository>()));

  // Cubits
  sl.registerFactory<DeviceListCubit>(
    () => DeviceListCubit(
      getDevicesUseCase: sl<GetDevicesUseCase>(),
      createDeviceUseCase: sl<CreateDeviceUseCase>(),
      updateDeviceUseCase: sl<UpdateDeviceUseCase>(),
      deleteDeviceUseCase: sl<DeleteDeviceUseCase>(),
    ),
  );
  sl.registerFactory<DeviceConfigCubit>(
    () => DeviceConfigCubit(sl<UpdateDeviceUseCase>()),
  );
}
