import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../domain/usecases/update_device_usecase.dart';
import 'device_config_state.dart';

class DeviceConfigCubit extends Cubit<DeviceConfigState> {
  final UpdateDeviceUseCase updateDeviceUseCase;

  DeviceConfigCubit(this.updateDeviceUseCase)
    : super(const DeviceConfigState());

  void initDevice(DeviceEntity device) {
    emit(
      DeviceConfigState(
        device: device,
        status: ConfigSubmissionStatus.unchanged,
      ),
    );
  }

  Future<void> submitConfig({
    required String imei,
    required String stationName,
    required int mainUdpPort,
    int? secondaryUdpPort,
    required String aisDeviceType,
  }) async {
    emit(
      state.copyWith(
        status: ConfigSubmissionStatus.sending,
        message: 'Đang gửi yêu cầu cấu hình...',
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          status: ConfigSubmissionStatus.sent,
          message: 'Đã gửi yêu cầu, đang chờ phản hồi từ thiết bị...',
        ),
      );

      final updatedDevice = await updateDeviceUseCase(
        DeviceEntity(
          imei: imei,
          stationName: stationName,
          aisPort: mainUdpPort,
          secondaryUdpPort: secondaryUdpPort,
          aisModuleType: aisDeviceType,
        ),
      ).timeout(AppConstants.configResponseTimeout);

      emit(
        state.copyWith(
          device: updatedDevice,
          status: ConfigSubmissionStatus.success,
          message: 'Cập nhật cấu hình thiết bị 4G thành công.',
        ),
      );
    } on TimeoutException {
      emit(
        state.copyWith(
          status: ConfigSubmissionStatus.noResponse,
          message: 'Không nhận được phản hồi từ thiết bị.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConfigSubmissionStatus.failure,
          message: 'Cấu hình thất bại: $e',
        ),
      );
    }
  }
}
