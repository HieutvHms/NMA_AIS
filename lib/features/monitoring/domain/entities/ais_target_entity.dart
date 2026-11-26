import 'package:equatable/equatable.dart';
import 'ais_type_mapper.dart';

class AisTargetEntity extends Equatable {
  final String mmsi;
  final int type;
  final double latitude;
  final double longitude;

  final DateTime updatedAt;

  final String? name;
  final String? mmsiType;
  final String? vesselType;
  final DateTime? utcTime;
  final DateTime? localTime;
  final String? receivedTime;
  final String? desMmsi;
  final double? voltage;
  final double? current;
  final String? lightStatus;
  final String? aidType;
  final int? boatA;
  final int? boatB;
  final int? boatC;
  final int? boatD;

  const AisTargetEntity({
    required this.mmsi,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.name,
    this.mmsiType = 'NMAJSC',
    this.vesselType,
    this.utcTime,
    this.localTime,
    this.receivedTime,
    this.desMmsi,
    this.voltage,
    this.current,
    this.lightStatus,
    this.aidType,
    this.boatA,
    this.boatB,
    this.boatC,
    this.boatD,
  });

  AisTargetKind get kind => AisTypeMapper.resolveKind(type);

  bool get isStationOrAton => AisTypeMapper.isStationOrAton(type);

  String get displayTitle {
    final trimmed = name?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : mmsi;
  }

  /// Định dạng thời gian cập nhật cuối theo chuẩn `HH:mm:ss`.
  String get formattedTime {
    final local = updatedAt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String get formattedUtc => _formatDateTime(utcTime ?? updatedAt.toUtc());

  String get formattedLocal =>
      _formatDateTime(localTime ?? updatedAt.toLocal());

  String get formattedReceived {
    final trimmed = receivedTime?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : formattedTime;
  }

  String? get formattedVoltage {
    final v = voltage;
    if (v == null) return null;
    return '${_formatNumber(v)}(V)';
  }

  String? get formattedCurrent {
    final c = current;
    if (c == null) return null;
    return '${_formatNumber(c)}(A)';
  }

  static String _formatNumber(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String _formatDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$ss';
  }

  AisTargetEntity copyWith({
    String? mmsi,
    int? type,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    String? name,
    String? mmsiType,
    String? vesselType,
    DateTime? utcTime,
    DateTime? localTime,
    String? receivedTime,
    String? desMmsi,
    double? voltage,
    double? current,
    String? lightStatus,
    String? aidType,
    int? boatA,
    int? boatB,
    int? boatC,
    int? boatD,
  }) {
    return AisTargetEntity(
      mmsi: mmsi ?? this.mmsi,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      mmsiType: mmsiType ?? this.mmsiType,
      vesselType: vesselType ?? this.vesselType,
      utcTime: utcTime ?? this.utcTime,
      localTime: localTime ?? this.localTime,
      receivedTime: receivedTime ?? this.receivedTime,
      desMmsi: desMmsi ?? this.desMmsi,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      lightStatus: lightStatus ?? this.lightStatus,
      aidType: aidType ?? this.aidType,
      boatA: boatA ?? this.boatA,
      boatB: boatB ?? this.boatB,
      boatC: boatC ?? this.boatC,
      boatD: boatD ?? this.boatD,
    );
  }

  @override
  List<Object?> get props => [
    mmsi,
    type,
    latitude,
    longitude,
    updatedAt,
    name,
    mmsiType,
    vesselType,
    utcTime,
    localTime,
    receivedTime,
    desMmsi,
    voltage,
    current,
    lightStatus,
    aidType,
    boatA,
    boatB,
    boatC,
    boatD,
  ];
}
