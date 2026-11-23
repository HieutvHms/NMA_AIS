import 'package:equatable/equatable.dart';
import '../../../domain/entities/device_entity.dart';
import '../widgets/device_sort_bottom_sheet.dart';

sealed class DeviceListState extends Equatable {
  const DeviceListState();

  @override
  List<Object?> get props => [];
}

class DeviceListInitial extends DeviceListState {
  const DeviceListInitial();
}

class DeviceListLoading extends DeviceListState {
  const DeviceListLoading();
}

class DeviceListLoaded extends DeviceListState {
  final List<DeviceEntity> devices;
  final String searchQuery;
  final DeviceStatus? statusFilter;
  final DeviceSortOption sortOption;
  final int totalCount;
  final int onlineCount;
  final int offlineCount;
  final int unknownCount;
  final String? actionMessage;

  const DeviceListLoaded({
    required this.devices,
    this.searchQuery = '',
    this.statusFilter,
    this.sortOption = DeviceSortOption.latestUpdated,
    this.totalCount = 0,
    this.onlineCount = 0,
    this.offlineCount = 0,
    this.unknownCount = 0,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [
    devices,
    searchQuery,
    statusFilter,
    sortOption,
    totalCount,
    onlineCount,
    offlineCount,
    unknownCount,
    actionMessage,
  ];

  DeviceListLoaded copyWith({
    List<DeviceEntity>? devices,
    String? searchQuery,
    DeviceStatus? statusFilter,
    bool clearFilter = false,
    DeviceSortOption? sortOption,
    int? totalCount,
    int? onlineCount,
    int? offlineCount,
    int? unknownCount,
    String? actionMessage,
  }) {
    return DeviceListLoaded(
      devices: devices ?? this.devices,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
      sortOption: sortOption ?? this.sortOption,
      totalCount: totalCount ?? this.totalCount,
      onlineCount: onlineCount ?? this.onlineCount,
      offlineCount: offlineCount ?? this.offlineCount,
      unknownCount: unknownCount ?? this.unknownCount,
      actionMessage: actionMessage,
    );
  }
}

class DeviceListError extends DeviceListState {
  final String message;

  const DeviceListError(this.message);

  @override
  List<Object?> get props => [message];
}
