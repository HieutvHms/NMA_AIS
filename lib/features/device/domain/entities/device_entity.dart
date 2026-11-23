import 'package:equatable/equatable.dart';

enum DeviceStatus {
  online('Online'),
  offline('Offline'),
  unknown('Chưa xác định');

  final String label;
  const DeviceStatus(this.label);

  static DeviceStatus fromString(String? value) {
    if (value == null) return DeviceStatus.unknown;
    final lower = value.toLowerCase().trim();
    if (lower == 'online' || lower == 'trực tuyến') return DeviceStatus.online;
    if (lower == 'offline' || lower == 'ngoại tuyến') {
      return DeviceStatus.offline;
    }
    return DeviceStatus.unknown;
  }
}

class DeviceEntity extends Equatable {
  final String imei;
  final String stationName;
  final String simSerial;
  final String mmsi;
  final int aisPort;
  final int? secondaryUdpPort;
  final DeviceStatus status;
  final int signalStrength;
  final DateTime? lastMessageTime;
  final DateTime? lastAisTime;
  final DateTime? offlineAtUtc;
  final bool isOldData;
  final String aisModuleType;

  const DeviceEntity({
    required this.imei,
    required this.stationName,
    this.simSerial = '',
    this.mmsi = '',
    required this.aisPort,
    this.secondaryUdpPort,
    this.status = DeviceStatus.unknown,
    this.signalStrength = 0,
    this.lastMessageTime,
    this.lastAisTime,
    this.offlineAtUtc,
    this.isOldData = false,
    this.aisModuleType = 'AIS AtoN Type 1',
  });

  bool get isOnline => status == DeviceStatus.online;

  @override
  List<Object?> get props => [
    imei,
    stationName,
    simSerial,
    mmsi,
    aisPort,
    secondaryUdpPort,
    status,
    signalStrength,
    lastMessageTime,
    lastAisTime,
    offlineAtUtc,
    isOldData,
    aisModuleType,
  ];
}
