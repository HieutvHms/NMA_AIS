import 'package:equatable/equatable.dart';

enum ManagedDeviceStatus {
  online('Online'),
  offline('Offline');

  final String label;
  const ManagedDeviceStatus(this.label);

  static ManagedDeviceStatus fromString(String? value) {
    if (value == null) return ManagedDeviceStatus.offline;
    final lower = value.toLowerCase().trim();
    if (lower == 'online' || lower == 'trực tuyến') {
      return ManagedDeviceStatus.online;
    }
    return ManagedDeviceStatus.offline;
  }
}

class ManagedDeviceEntity extends Equatable {
  final String imei;
  final String stationName;
  final String simSerial;
  final int aisPort;
  final int? secondaryUdpPort;
  final ManagedDeviceStatus status;
  final int signalStrength;
  final String mmsi;
  final DateTime? lastMessageTime;
  final DateTime? lastAisTime;
  final String aisModuleType;
  final DateTime? updatedAt;

  const ManagedDeviceEntity({
    required this.imei,
    required this.stationName,
    this.simSerial = '',
    required this.aisPort,
    this.secondaryUdpPort,
    this.status = ManagedDeviceStatus.online,
    this.signalStrength = 0,
    this.lastMessageTime,
    this.lastAisTime,
    this.mmsi = '',
    this.aisModuleType = 'AIS AtoN Type 1',
    this.updatedAt,
  });

  bool get isOnline => status == ManagedDeviceStatus.online;

  /// Quy đổi cường độ sóng CSQ (0-31) sang phần trăm hiển thị trực quan
  int get signalPercentage {
    if (!isOnline || signalStrength <= 0) return 0;
    final percent = ((signalStrength.clamp(0, 31) / 31) * 100).round();
    return percent;
  }

  @override
  List<Object?> get props => [
    imei,
    stationName,
    simSerial,
    aisPort,
    secondaryUdpPort,
    status,
    mmsi,
    signalStrength,
    lastMessageTime,
    lastAisTime,
    aisModuleType,
    updatedAt,
  ];
}
