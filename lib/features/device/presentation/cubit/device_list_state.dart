import 'package:equatable/equatable.dart';
import '../../domain/entities/device_entity.dart';

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
  final String? actionMessage;

  const DeviceListLoaded({
    required this.devices,
    this.searchQuery = '',
    this.statusFilter,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [devices, searchQuery, statusFilter, actionMessage];

  DeviceListLoaded copyWith({
    List<DeviceEntity>? devices,
    String? searchQuery,
    DeviceStatus? statusFilter,
    bool clearFilter = false,
    String? actionMessage,
  }) {
    return DeviceListLoaded(
      devices: devices ?? this.devices,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
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
