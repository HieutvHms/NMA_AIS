import 'package:equatable/equatable.dart';
import '../../../device/domain/entities/device_entity.dart';
import '../../../monitoring/domain/entities/ais_target_entity.dart';

class OverviewState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<DeviceEntity> devices;
  final List<AisTargetEntity> aisTargets;
  final String? devicesError;
  final String? aisError;
  final DateTime? lastUpdatedAt;

  const OverviewState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.devices = const [],
    this.aisTargets = const [],
    this.devicesError,
    this.aisError,
    this.lastUpdatedAt,
  });

  int get totalDevices => devices.length;
  int get onlineDevices => devices.where((d) => d.isOnline).length;
  int get offlineDevices =>
      devices.where((d) => d.status == DeviceStatus.offline).length;

  int get totalAisTargets => aisTargets.length;
  int get stationOrAtonCount =>
      aisTargets.where((t) => t.isStationOrAton).length;
  int get vesselCount => totalAisTargets - stationOrAtonCount;

  List<DeviceEntity> get offlineDeviceList => devices
      .where((d) => d.status == DeviceStatus.offline)
      .toList(growable: false);

  List<AisTargetEntity> get abnormalAtonList => aisTargets.where((t) {
    if (!t.isStationOrAton) return false;
    final lowVoltage =
        t.voltage != null && t.voltage! > 0 && t.voltage! < 11.5;
    final lightError = t.lightStatus?.toUpperCase() == 'ERROR';
    return lowVoltage || lightError;
  }).toList(growable: false);

  int get totalAlerts => offlineDeviceList.length + abnormalAtonList.length;

  bool get hasBothErrors =>
      devicesError != null &&
      aisError != null &&
      devices.isEmpty &&
      aisTargets.isEmpty;

  String get formattedLastUpdated {
    final dt = lastUpdatedAt;
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  OverviewState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<DeviceEntity>? devices,
    List<AisTargetEntity>? aisTargets,
    String? devicesError,
    bool clearDevicesError = false,
    String? aisError,
    bool clearAisError = false,
    DateTime? lastUpdatedAt,
  }) {
    return OverviewState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      devices: devices ?? this.devices,
      aisTargets: aisTargets ?? this.aisTargets,
      devicesError: clearDevicesError
          ? null
          : (devicesError ?? this.devicesError),
      aisError: clearAisError ? null : (aisError ?? this.aisError),
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    devices,
    aisTargets,
    devicesError,
    aisError,
    lastUpdatedAt,
  ];
}
