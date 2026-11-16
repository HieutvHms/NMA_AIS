import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/ais_config_repository.dart';
import 'ais_config_state.dart';

class AisConfigCubit extends Cubit<AisConfigState> {
  final AisConfigRepository _repository;

  AisConfigCubit(this._repository) : super(const AisConfigState());

  Future<void> loadConfig(String deviceId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final config = await _repository.getAisConfig(deviceId);
      emit(state.copyWith(config: config, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  Future<void> updateMmsi(String deviceId, String mmsi) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final updated = await _repository.updateMmsi(
        deviceId: deviceId,
        mmsi: mmsi,
      );
      emit(state.copyWith(
        config: updated,
        isLoading: false,
        isSuccess: true,
        message: 'Cập nhật MMSI thành công.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: 'Cập nhật thất bại: $e',
      ));
    }
  }
}

