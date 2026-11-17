import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/device_management/data/datasources/device_management_remote_datasource.dart';
import '../../../features/device_management/data/repositories/device_management_repository_impl.dart';
import '../../../features/device_management/domain/repositories/device_management_repository.dart';
import '../../../features/device_management/domain/usecases/create_managed_device_usecase.dart';
import '../../../features/device_management/domain/usecases/delete_managed_device_usecase.dart';
import '../../../features/device_management/domain/usecases/get_managed_devices_usecase.dart';
import '../../../features/device_management/domain/usecases/update_managed_device_usecase.dart';
import '../../../features/device_management/presentation/cubit/device_management_cubit.dart';

void registerDeviceManagementModule(GetIt sl) {
  // DataSource
  sl.registerLazySingleton<DeviceManagementRemoteDataSource>(
    () => DeviceManagementRemoteDataSourceImpl(
      sl<DioClient>().dio,
      sl<LocalStorage>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<DeviceManagementRepository>(
    () =>
        DeviceManagementRepositoryImpl(sl<DeviceManagementRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(
    () => GetManagedDevicesUseCase(sl<DeviceManagementRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateManagedDeviceUseCase(sl<DeviceManagementRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateManagedDeviceUseCase(sl<DeviceManagementRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteManagedDeviceUseCase(sl<DeviceManagementRepository>()),
  );

  // Cubit
  sl.registerFactory<DeviceManagementCubit>(
    () => DeviceManagementCubit(
      getManagedDevicesUseCase: sl<GetManagedDevicesUseCase>(),
      createManagedDeviceUseCase: sl<CreateManagedDeviceUseCase>(),
      updateManagedDeviceUseCase: sl<UpdateManagedDeviceUseCase>(),
      deleteManagedDeviceUseCase: sl<DeleteManagedDeviceUseCase>(),
    ),
  );
}
