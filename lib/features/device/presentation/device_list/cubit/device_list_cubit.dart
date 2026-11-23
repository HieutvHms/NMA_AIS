import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/error_mapper.dart';
import '../../../domain/entities/device_entity.dart';
import '../../../domain/usecases/get_devices_usecase.dart';
import '../widgets/device_sort_bottom_sheet.dart';
import 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  final GetDevicesUseCase getDevicesUseCase;

  List<DeviceEntity> _cachedDevices = [];
  String _currentQuery = '';
  DeviceStatus? _currentStatus;
  DeviceSortOption _currentSort = DeviceSortOption.latestUpdated;

  DeviceListCubit({required this.getDevicesUseCase})
    : super(const DeviceListInitial());

  Future<void> loadDevices({
    String? query,
    DeviceStatus? statusFilter,
    bool clearFilter = false,
    DeviceSortOption? sortOption,
    bool forceRefresh = false,
  }) async {
    _currentQuery = query ?? _currentQuery;
    if (clearFilter) {
      _currentStatus = null;
    } else if (statusFilter != null) {
      _currentStatus = statusFilter;
    }
    if (sortOption != null) {
      _currentSort = sortOption;
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
        emit(DeviceListError(ErrorMapper.map(e).message));
        return;
      }
    }

    // Lọc tức thì trên bộ nhớ đệm (In-memory Filtering): 0ms, mượt mà 60 FPS
    _applyFilterAndEmit();
  }

  void _applyFilterAndEmit() {
    var queried = List<DeviceEntity>.from(_cachedDevices);

    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.trim().toLowerCase();
      queried = queried.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    final totalCount = queried.length;
    final onlineCount = queried
        .where((e) => e.status == DeviceStatus.online)
        .length;
    final offlineCount = queried
        .where((e) => e.status == DeviceStatus.offline)
        .length;
    final unknownCount = queried
        .where((e) => e.status == DeviceStatus.unknown)
        .length;

    final result = _currentStatus != null
        ? queried.where((e) => e.status == _currentStatus).toList()
        : queried;

    _sortDevices(result);

    emit(
      DeviceListLoaded(
        devices: result,
        searchQuery: _currentQuery,
        statusFilter: _currentStatus,
        sortOption: _currentSort,
        totalCount: totalCount,
        onlineCount: onlineCount,
        offlineCount: offlineCount,
        unknownCount: unknownCount,
      ),
    );
  }

  void _sortDevices(List<DeviceEntity> list) {
    switch (_currentSort) {
      case DeviceSortOption.latestUpdated:
        list.sort((a, b) {
          final aTime = a.lastMessageTime;
          final bTime = b.lastMessageTime;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
      case DeviceSortOption.nameAsc:
        list.sort(
          (a, b) => a.stationName.toLowerCase().compareTo(
            b.stationName.toLowerCase(),
          ),
        );
    }
  }
}
