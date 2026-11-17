import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../domain/usecases/create_device_usecase.dart';
import '../../../domain/usecases/delete_device_usecase.dart';
import '../../../domain/usecases/get_devices_usecase.dart';
import '../../../domain/usecases/update_device_usecase.dart';
import 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  final GetDevicesUseCase getDevicesUseCase;
  final CreateDeviceUseCase createDeviceUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;

  List<DeviceEntity> _cachedDevices = [];
  String _currentQuery = '';
  DeviceStatus? _currentStatus;

  DeviceListCubit({
    required this.getDevicesUseCase,
    required this.createDeviceUseCase,
    required this.updateDeviceUseCase,
    required this.deleteDeviceUseCase,
  }) : super(const DeviceListInitial());

  Future<void> loadDevices({
    String? query,
    DeviceStatus? statusFilter,
    bool clearFilter = false,
    bool forceRefresh = false,
  }) async {
    _currentQuery = query ?? _currentQuery;
    if (clearFilter) {
      _currentStatus = null;
    } else if (statusFilter != null) {
      _currentStatus = statusFilter;
    }

    // Nếu chưa có cache hoặc người dùng yêu cầu forceRefresh
    if (_cachedDevices.isEmpty || forceRefresh) {
      // Chỉ emit Loading khi chưa có dữ liệu nào trên màn hình để tránh nhấp nháy
      if (state is! DeviceListLoaded) {
        emit(const DeviceListLoading());
      }
      try {
        _cachedDevices = await getDevicesUseCase();
      } catch (e) {
        emit(DeviceListError(e.toString()));
        return;
      }
    }

    // Lọc tức thì trên bộ nhớ đệm (In-memory Filtering): 0ms, mượt mà 60 FPS
    _applyFilterAndEmit();
  }

  void _applyFilterAndEmit() {
    var result = List<DeviceEntity>.from(_cachedDevices);

    if (_currentStatus != null) {
      result = result.where((e) => e.status == _currentStatus).toList();
    }

    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.trim().toLowerCase();
      result = result.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    emit(
      DeviceListLoaded(
        devices: result,
        searchQuery: _currentQuery,
        statusFilter: _currentStatus,
      ),
    );
  }

  Future<void> createDevice(DeviceEntity device) async {
    try {
      await createDeviceUseCase(device);
      await loadDevices(forceRefresh: true);
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }

  Future<void> updateDevice(DeviceEntity device) async {
    try {
      await updateDeviceUseCase(device);
      await loadDevices(forceRefresh: true);
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }

  Future<void> deleteDevice(String imei) async {
    try {
      await deleteDeviceUseCase(imei);
      await loadDevices(forceRefresh: true);
    } catch (e) {
      emit(DeviceListError(e.toString()));
    }
  }
}
