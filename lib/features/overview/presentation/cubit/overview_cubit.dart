import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../device/domain/entities/device_entity.dart';
import '../../../device/domain/usecases/get_devices_usecase.dart';
import '../../../monitoring/domain/entities/ais_target_entity.dart';
import '../../../monitoring/domain/usecases/get_all_map_targets_usecase.dart';
import 'overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  final GetDevicesUseCase _getDevicesUseCase;
  final GetAllMapTargetsUseCase _getAllMapTargetsUseCase;

  OverviewCubit({
    required GetDevicesUseCase getDevicesUseCase,
    required GetAllMapTargetsUseCase getAllMapTargetsUseCase,
  }) : _getDevicesUseCase = getDevicesUseCase,
       _getAllMapTargetsUseCase = getAllMapTargetsUseCase,
       super(const OverviewState());

  Future<void> loadOverview({bool isRefresh = false}) async {
    if (state.isRefreshing) return;

    emit(
      state.copyWith(
        isLoading: !isRefresh && state.lastUpdatedAt == null,
        isRefreshing: isRefresh,
        clearDevicesError: true,
        clearAisError: true,
      ),
    );

    List<DeviceEntity> nextDevices = state.devices;
    List<AisTargetEntity> nextAis = state.aisTargets;
    String? nextDevicesError;
    String? nextAisError;

    // Gọi song song 2 API độc lập; nếu 1 API lỗi thì phần còn lại vẫn hiển thị bình thường.
    await Future.wait([
      () async {
        try {
          nextDevices = await _getDevicesUseCase();
        } on Failure catch (f) {
          nextDevicesError = f.message;
        } catch (e) {
          nextDevicesError = ErrorMapper.map(e).message;
        }
      }(),
      () async {
        try {
          nextAis = await _getAllMapTargetsUseCase(forceRefresh: isRefresh);
        } on Failure catch (f) {
          nextAisError = f.message;
        } catch (e) {
          nextAisError = ErrorMapper.map(e).message;
        }
      }(),
    ]);

    if (isClosed) return;

    emit(
      state.copyWith(
        isLoading: false,
        isRefreshing: false,
        devices: nextDevices,
        aisTargets: nextAis,
        devicesError: nextDevicesError,
        clearDevicesError: nextDevicesError == null,
        aisError: nextAisError,
        clearAisError: nextAisError == null,
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }
}
