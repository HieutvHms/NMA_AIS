import 'package:get_it/get_it.dart';
import '../../../features/device/domain/usecases/get_devices_usecase.dart';
import '../../../features/monitoring/domain/usecases/get_all_map_targets_usecase.dart';
import '../../../features/overview/presentation/cubit/overview_cubit.dart';

void registerOverviewModule(GetIt sl) {
  sl.registerFactory<OverviewCubit>(
    () => OverviewCubit(
      getDevicesUseCase: sl<GetDevicesUseCase>(),
      getAllMapTargetsUseCase: sl<GetAllMapTargetsUseCase>(),
    ),
  );
}
