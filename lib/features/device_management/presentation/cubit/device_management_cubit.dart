import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/managed_device_entity.dart';
import '../../domain/usecases/create_managed_device_usecase.dart';
import '../../domain/usecases/delete_managed_device_usecase.dart';
import '../../domain/usecases/get_managed_devices_usecase.dart';
import '../../domain/usecases/update_managed_device_usecase.dart';
import 'device_management_state.dart';

class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final GetManagedDevicesUseCase getManagedDevicesUseCase;
  final CreateManagedDeviceUseCase createManagedDeviceUseCase;
  final UpdateManagedDeviceUseCase updateManagedDeviceUseCase;
  final DeleteManagedDeviceUseCase deleteManagedDeviceUseCase;

  List<ManagedDeviceEntity> _cachedDevices = [];
  String _currentQuery = '';
  ManagedDeviceStatus? _currentStatus;

  DeviceManagementCubit({
    required this.getManagedDevicesUseCase,
    required this.createManagedDeviceUseCase,
    required this.updateManagedDeviceUseCase,
    required this.deleteManagedDeviceUseCase,
  }) : super(const DeviceManagementInitial());

  Future<void> loadDevices({
    String? query,
    ManagedDeviceStatus? statusFilter,
    bool clearFilter = false,
    bool forceRefresh = false,
    String? actionMessage,
  }) async {
    _currentQuery = query ?? _currentQuery;
    if (clearFilter) {
      _currentStatus = null;
    } else if (statusFilter != null) {
      _currentStatus = statusFilter;
    }

    if (_cachedDevices.isEmpty || forceRefresh) {
      if (state is! DeviceManagementLoaded) {
        emit(const DeviceManagementLoading());
      }
      try {
        _cachedDevices = await getManagedDevicesUseCase();
      } catch (e) {
        emit(DeviceManagementError(ErrorMapper.map(e).message));
        return;
      }
    }

    _applyFilterAndEmit(actionMessage: actionMessage);
  }

  void _applyFilterAndEmit({String? actionMessage}) {
    var result = List<ManagedDeviceEntity>.from(_cachedDevices);

    if (_currentStatus != null) {
      result = result.where((e) => e.status == _currentStatus).toList();
    }

    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.trim().toLowerCase();
      result = result.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.mmsi.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    emit(
      DeviceManagementLoaded(
        devices: result,
        searchQuery: _currentQuery,
        statusFilter: _currentStatus,
        actionMessage: actionMessage,
      ),
    );
  }

  Future<void> createDevice(ManagedDeviceEntity device) async {
    try {
      await createManagedDeviceUseCase(device);
      await loadDevices(
        forceRefresh: true,
        actionMessage: 'Đã thêm mới thiết bị "${device.stationName}"',
      );
    } catch (e) {
      emit(DeviceManagementError(ErrorMapper.map(e).message));
      await loadDevices(forceRefresh: false);
    }
  }

  Future<void> updateDevice(ManagedDeviceEntity device) async {
    try {
      await updateManagedDeviceUseCase(device);
      await loadDevices(
        forceRefresh: true,
        actionMessage: 'Đã cập nhật thiết bị "${device.stationName}"',
      );
    } catch (e) {
      emit(DeviceManagementError(ErrorMapper.map(e).message));
      await loadDevices(forceRefresh: false);
    }
  }

  Future<void> deleteDevice(ManagedDeviceEntity device) async {
    try {
      await deleteManagedDeviceUseCase(device.imei);
      await loadDevices(
        forceRefresh: true,
        actionMessage: 'Đã xóa thiết bị "${device.stationName}"',
      );
    } catch (e) {
      emit(DeviceManagementError(ErrorMapper.map(e).message));
      await loadDevices(forceRefresh: false);
    }
  }
}
