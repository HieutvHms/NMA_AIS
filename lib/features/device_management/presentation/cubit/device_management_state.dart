import 'package:equatable/equatable.dart';
import '../../domain/entities/managed_device_entity.dart';

sealed class DeviceManagementState extends Equatable {
  const DeviceManagementState();

  @override
  List<Object?> get props => [];
}

class DeviceManagementInitial extends DeviceManagementState {
  const DeviceManagementInitial();
}

class DeviceManagementLoading extends DeviceManagementState {
  const DeviceManagementLoading();
}

class DeviceManagementLoaded extends DeviceManagementState {
  final List<ManagedDeviceEntity> devices;
  final String searchQuery;
  final ManagedDeviceStatus? statusFilter;
  final String? actionMessage;

  const DeviceManagementLoaded({
    required this.devices,
    this.searchQuery = '',
    this.statusFilter,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [
    devices,
    searchQuery,
    statusFilter,
    actionMessage,
  ];
}

class DeviceManagementError extends DeviceManagementState {
  final String message;

  const DeviceManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

