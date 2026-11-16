import 'package:equatable/equatable.dart';

enum DeviceStatus {
  online('Online'),
  offline('Offline'),
  maintenance('Đang bảo trì');

  final String label;
  const DeviceStatus(this.label);

  static DeviceStatus fromString(String? value) {
    if (value == null) return DeviceStatus.offline;
    final lower = value.toLowerCase().trim();
    if (lower == 'online' || lower == 'trực tuyến') return DeviceStatus.online;
    if (lower == 'maintenance' || lower == 'đang bảo trì') {
      return DeviceStatus.maintenance;
    }
    return DeviceStatus.offline;
  }
}

class DeviceEntity extends Equatable {
  final String id;
  final String imei; // Key chính
  final String stationName; // Tên trạm / Tên thiết bị
  final String simSerial; // Serial SIM
  final int aisPort; // Cổng nhận dữ liệu AIS (Main UDP Port)
  final int? secondaryUdpPort; // UDP Port phụ
  final DeviceStatus status; // Trạng thái
  final int signalStrength; // Cường độ sóng (0 - 31 hoặc %)
  final DateTime? lastMessageTime; // Thời gian gửi tin gần nhất
  final DateTime? lastAisTime; // Thời gian nhận AIS gần nhất
  final String aisModuleType; // Loại module AIS
  final DateTime? updatedAt; // Cập nhật lần cuối

  const DeviceEntity({
    required this.id,
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
        id,
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

