import '../../domain/entities/managed_device_entity.dart';

class ManagedDeviceModel extends ManagedDeviceEntity {
  const ManagedDeviceModel({
    required super.imei,
    required super.stationName,
    super.simSerial = '',
    super.mmsi = '',
    required super.aisPort,
    super.secondaryUdpPort,
    super.status = ManagedDeviceStatus.online,
    super.signalStrength = 0,
    super.lastMessageTime,
    super.lastAisTime,
    super.aisModuleType = 'AIS AtoN Type 1',
    super.updatedAt,
  });

  factory ManagedDeviceModel.fromJson(Map<String, dynamic> json) {
    return ManagedDeviceModel(
      imei: json['imei']?.toString() ?? '',
      stationName: json['name']?.toString() ?? '',
      simSerial: json['sim']?.toString() ?? '',
      mmsi: json['mmsi']?.toString() ?? '',
      aisPort: int.tryParse(json['udpPortMain']?.toString() ?? '') ?? 0,
      secondaryUdpPort: int.tryParse(json['udpPortSup']?.toString() ?? ''),
      status: ManagedDeviceStatus.fromString(json['status']?.toString()),
      signalStrength:
          int.tryParse(json['signalStrength']?.toString() ?? '26') ?? 26,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : (json['updateAt'] != null
                ? DateTime.tryParse(json['updateAt'].toString())
                : null),
      lastAisTime: json['lastAisTime'] != null
          ? DateTime.tryParse(json['lastAisTime'].toString())
          : null,
      aisModuleType:
          json['aisModuleType']?.toString() ??
          json['aisDeviceType']?.toString() ??
          'AIS AtoN Type 1',
      updatedAt: json['updateAt'] != null
          ? DateTime.tryParse(json['updateAt'].toString())
          : (json['updatedAt'] != null
                ? DateTime.tryParse(json['updatedAt'].toString())
                : (json['createdAt'] != null
                      ? DateTime.tryParse(json['createdAt'].toString())
                      : null)),
    );
  }

  factory ManagedDeviceModel.fromEntity(ManagedDeviceEntity entity) {
    return ManagedDeviceModel(
      imei: entity.imei,
      stationName: entity.stationName,
      simSerial: entity.simSerial,
      mmsi: entity.mmsi,
      aisPort: entity.aisPort,
      secondaryUdpPort: entity.secondaryUdpPort,
      status: entity.status,
      signalStrength: entity.signalStrength,
      lastMessageTime: entity.lastMessageTime,
      lastAisTime: entity.lastAisTime,
      aisModuleType: entity.aisModuleType,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson(int userId) {
    return {
      'userId': userId,
      'imei': imei,
      'mmsi': mmsi,
      'sim': simSerial,
      'name': stationName,
      'udpPortMain': aisPort.toString(),
      'udpPortSup': secondaryUdpPort != null && secondaryUdpPort! > 0
          ? secondaryUdpPort.toString()
          : '',
    };
  }

  ManagedDeviceModel copyWith({
    String? imei,
    String? stationName,
    String? simSerial,
    String? mmsi,
    int? aisPort,
    int? secondaryUdpPort,
    ManagedDeviceStatus? status,
    int? signalStrength,
    DateTime? lastMessageTime,
    DateTime? lastAisTime,
    String? aisModuleType,
    DateTime? updatedAt,
  }) {
    return ManagedDeviceModel(
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
      aisModuleType: aisModuleType ?? this.aisModuleType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
