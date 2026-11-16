import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/create_device_usecase.dart';
import '../../domain/usecases/delete_device_usecase.dart';
import '../../domain/usecases/get_devices_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';
import 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  final GetDevicesUseCase getDevicesUseCase;
  final CreateDeviceUseCase createDeviceUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;

  String _currentQuery = '';
  DeviceStatus? _currentStatus;

  DeviceListCubit({
    required this.getDevicesUseCase,
    required this.createDeviceUseCase,
    required this.updateDeviceUseCase,
    required this.deleteDeviceUseCase,
  }) : super(const DeviceListInitial());

  Future<void> loadDevices({String? query, DeviceStatus? statusFilter, bool clearFilter = false}) async {
    _currentQuery = query ?? _currentQuery;
    if (clearFilter) {
      _currentStatus = null;
    } else if (statusFilter != null) {
      _currentStatus = statusFilter;
    }

    emit(const DeviceListLoading());
    try {
      final devices = await getDevicesUseCase(
        query: _currentQuery,
        statusFilter: _currentStatus,
      );
      emit(DeviceListLoaded(
        devices: devices,
        searchQuery: _currentQuery,
        statusFilter: _currentStatus,
      ));
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }

  Future<void> createDevice(DeviceEntity device) async {
    try {
      await createDeviceUseCase(device);
      await loadDevices();
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }

  Future<void> updateDevice(DeviceEntity device) async {
    try {
      await updateDeviceUseCase(device);
      await loadDevices();
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }

  Future<void> deleteDevice(String imei) async {
    try {
      await deleteDeviceUseCase(imei);
      await loadDevices();
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }
}
