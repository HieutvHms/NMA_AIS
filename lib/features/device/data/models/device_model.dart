import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.imei,
    required super.stationName,
    super.simSerial = '',
    required super.aisPort,
    super.secondaryUdpPort,
    super.status = DeviceStatus.online,
    super.signalStrength = 0,
    super.lastMessageTime,
    super.lastAisTime,
    super.aisModuleType = 'AIS AtoN Type 1',
    super.updatedAt,
  });

  // Getter tương thích ngược nếu cần
  String get deviceName => stationName;
  int? get mainUdpPort => aisPort;
  String? get aisDeviceType => aisModuleType;

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      imei: json['imei']?.toString() ?? '',
      stationName:
          json['stationName']?.toString() ??
          json['deviceName']?.toString() ??
          '',
      simSerial: json['simSerial']?.toString() ?? '',
      aisPort:
          int.tryParse(
            json['aisPort']?.toString() ??
                json['mainUdpPort']?.toString() ??
                '6000',
          ) ??
          6000,
      secondaryUdpPort: int.tryParse(
        json['secondaryUdpPort']?.toString() ?? '',
      ),
      status: DeviceStatus.fromString(json['status']?.toString()),
      signalStrength:
          int.tryParse(json['signalStrength']?.toString() ?? '0') ?? 0,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : null,
      lastAisTime: json['lastAisTime'] != null
          ? DateTime.tryParse(json['lastAisTime'].toString())
          : null,
      aisModuleType:
          json['aisModuleType']?.toString() ??
          json['aisDeviceType']?.toString() ??
          'AIS AtoN Type 1',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imei': imei,
      'stationName': stationName,
      'simSerial': simSerial,
      'aisPort': aisPort,
      'secondaryUdpPort': secondaryUdpPort,
      'status': status.name,
      'signalStrength': signalStrength,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastAisTime': lastAisTime?.toIso8601String(),
      'aisModuleType': aisModuleType,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? imei,
    String? stationName,
    String? simSerial,
    int? aisPort,
    int? secondaryUdpPort,
    DeviceStatus? status,
    int? signalStrength,
    DateTime? lastMessageTime,
    DateTime? lastAisTime,
    String? aisModuleType,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      imei: imei ?? this.imei,
      stationName: stationName ?? this.stationName,
      simSerial: simSerial ?? this.simSerial,
      aisPort: aisPort ?? this.aisPort,
      secondaryUdpPort: secondaryUdpPort ?? this.secondaryUdpPort,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastAisTime: lastAisTime ?? this.lastAisTime,
      aisModuleType: aisModuleType ?? this.aisModuleType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
