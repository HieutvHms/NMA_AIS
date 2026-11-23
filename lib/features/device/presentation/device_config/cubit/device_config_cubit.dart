import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device_entity.dart';
import 'device_config_state.dart';

class DeviceConfigCubit extends Cubit<DeviceConfigState> {
  DeviceConfigCubit() : super(const DeviceConfigState());

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
        status: ConfigSubmissionStatus.failure,
        message:
            'Tính năng cập nhật cấu hình thiết bị 4G hiện chưa hỗ trợ API.',
      ),
    );
  }
}
