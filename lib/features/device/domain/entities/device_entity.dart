import 'package:equatable/equatable.dart';

enum DeviceStatus {
  online('Online'),
  offline('Offline');

  final String label;
  const DeviceStatus(this.label);

  static DeviceStatus fromString(String? value) {
    if (value == null) return DeviceStatus.offline;
    final lower = value.toLowerCase().trim();
    if (lower == 'online' || lower == 'trực tuyến') return DeviceStatus.online;
    return DeviceStatus.offline;
  }
}

class DeviceEntity extends Equatable {
  final String imei;
  final String stationName;
  final String simSerial;
  final int aisPort;
  final int? secondaryUdpPort;
  final DeviceStatus status;
  final int signalStrength;
  final DateTime? lastMessageTime;
  final DateTime? lastAisTime;
  final String aisModuleType;
  final DateTime? updatedAt;

  const DeviceEntity({
    required this.imei,
    required this.stationName,
    this.simSerial = '',
    required this.aisPort,
    this.secondaryUdpPort,
    this.status = DeviceStatus.online,
    this.signalStrength = 0,
    this.lastMessageTime,
    this.lastAisTime,
    this.aisModuleType = 'AIS AtoN Type 1',
    this.updatedAt,
  });

  bool get isOnline => status == DeviceStatus.online;

  @override
  List<Object?> get props => [
    imei,
    stationName,
    simSerial,
    aisPort,
    secondaryUdpPort,
    status,
    signalStrength,
    lastMessageTime,
    lastAisTime,
    aisModuleType,
    updatedAt,
  ];
}
