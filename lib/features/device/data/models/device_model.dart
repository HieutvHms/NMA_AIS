import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.imei,
    required super.stationName,
    super.simSerial = '',
    super.mmsi = '',
    required super.aisPort,
    super.secondaryUdpPort,
    super.status = DeviceStatus.unknown,
    super.signalStrength = 0,
    super.lastMessageTime,
    super.lastAisTime,
    super.offlineAtUtc,
    super.isOldData = false,
    super.aisModuleType = 'AIS AtoN Type 1',
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final imei = json['imei']?.toString().trim() ?? '';
    final latest = json['latestMessage'] is Map<String, dynamic>
        ? json['latestMessage'] as Map<String, dynamic>
        : null;

    final rawName = latest?['deviceName']?.toString().trim() ?? '';
    final stationName = rawName.isNotEmpty
        ? rawName
        : (imei.isNotEmpty ? 'Trạm $imei' : 'Chưa đặt tên');

    final portRaw =
        json['udpPort']?.toString() ?? latest?['udpPort']?.toString() ?? '0';
    final aisPort = int.tryParse(portRaw) ?? 0;

    final receivedTime = _parseDateTime(latest?['receivedAtUtc']);
    final rawAisTime = _parseDateTime(latest?['aisThoiGian']);
    // Bỏ qua mốc thời gian mặc định 2000-01-01 khi thiết bị chưa có dữ liệu AIS
    final lastAisTime = (rawAisTime != null && rawAisTime.year > 2000)
        ? rawAisTime
        : null;

    return DeviceModel(
      imei: imei,
      stationName: stationName,
      simSerial: latest?['simimei']?.toString().trim() ?? '',
      mmsi:
          latest?['mmsi']?.toString().trim() ??
          json['mmsi']?.toString().trim() ??
          '',
      aisPort: aisPort,
      status: DeviceStatus.fromString(json['connectionStatus']?.toString()),
      signalStrength: int.tryParse(latest?['csq']?.toString() ?? '0') ?? 0,
      lastMessageTime: receivedTime,
      lastAisTime: lastAisTime,
      offlineAtUtc: _parseDateTime(json['offlineAtUtc']),
      isOldData: latest?['isOldData'] == true,
    );
  }

  DeviceModel copyWith({
    String? imei,
    String? stationName,
    String? simSerial,
    String? mmsi,
    int? aisPort,
    int? secondaryUdpPort,
    DeviceStatus? status,
    int? signalStrength,
    DateTime? lastMessageTime,
    DateTime? lastAisTime,
    DateTime? offlineAtUtc,
    bool? isOldData,
    String? aisModuleType,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      imei: imei ?? this.imei,
      stationName: stationName ?? this.stationName,
      simSerial: simSerial ?? this.simSerial,
      mmsi: mmsi ?? this.mmsi,
      aisPort: aisPort ?? this.aisPort,
      secondaryUdpPort: secondaryUdpPort ?? this.secondaryUdpPort,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastAisTime: lastAisTime ?? this.lastAisTime,
      offlineAtUtc: offlineAtUtc ?? this.offlineAtUtc,
      isOldData: isOldData ?? this.isOldData,
      aisModuleType: aisModuleType ?? this.aisModuleType,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
