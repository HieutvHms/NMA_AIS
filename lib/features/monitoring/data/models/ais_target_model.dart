import '../../domain/entities/ais_target_entity.dart';

class _AisJsonKeys {
  _AisJsonKeys._();

  static const String sourceMmsi = 'sourceMMSI';
  static const String mmsi = 'mmsi';
  static const String messageType = 'messageType';
  static const String aidName = 'aidName';
  static const String lat = 'lat';
  static const String latitude = 'latitude';
  static const String lng = 'lng';
  static const String longitude = 'longitude';
  static const String voltage = 'voltage';
  static const String lightStatus = 'lightStatus';
  static const String current = 'current';
  static const String msg21BoatA = 'msg21BoatA';
  static const String msg21BoatB = 'msg21BoatB';
  static const String msg21BoatC = 'msg21BoatC';
  static const String msg21BoatD = 'msg21BoatD';
  static const String thoiGianNhan = 'thoiGianNhan';
}

class AisTargetModel extends AisTargetEntity {
  const AisTargetModel({
    required super.mmsi,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.updatedAt,
    super.name,
    super.mmsiType,
    super.vesselType,
    super.utcTime,
    super.localTime,
    super.receivedTime,
    super.desMmsi,
    super.voltage,
    super.current,
    super.lightStatus,
    super.aidType,
    super.boatA,
    super.boatB,
    super.boatC,
    super.boatD,
  });

  factory AisTargetModel.fromJson(Map<String, dynamic> json) {
    final rawMmsi =
        json[_AisJsonKeys.sourceMmsi] ??
        json[_AisJsonKeys.mmsi] ??
        json['MMSI'];
    final rawType = json[_AisJsonKeys.messageType];
    final rawLat = json[_AisJsonKeys.lat] ?? json[_AisJsonKeys.latitude];
    final rawLng = json[_AisJsonKeys.lng] ?? json[_AisJsonKeys.longitude];
    final rawTime = json[_AisJsonKeys.thoiGianNhan];
    final parsedTime = _parseDateTime(rawTime);
    final rawUtc = json['utc'];
    final rawLocal = json['local'];

    return AisTargetModel(
      mmsi: rawMmsi?.toString().trim() ?? '',
      type: _parseInt(rawType, fallback: 1),
      latitude: _parseDouble(rawLat) ?? 0.0,
      longitude: _parseDouble(rawLng) ?? 0.0,
      updatedAt: parsedTime,
      name: _parseNullableString(json[_AisJsonKeys.aidName]),
      mmsiType: _parseNullableString(json['mmsiType']) ?? 'NMAJSC',
      vesselType: _parseNullableString(json['vesselType']),
      utcTime: rawUtc != null ? _parseDateTime(rawUtc) : parsedTime.toUtc(),
      localTime: rawLocal != null
          ? _parseDateTime(rawLocal)
          : parsedTime.toLocal(),
      receivedTime: _parseNullableString(json['received'] ?? json['Received']),
      desMmsi: _parseNullableString(json['desMmsi']),
      voltage: _parseDouble(json[_AisJsonKeys.voltage]),
      current: _parseDouble(json[_AisJsonKeys.current]),
      lightStatus: _parseLightStatus(json[_AisJsonKeys.lightStatus]),
      aidType: _parseNullableString(json['aidType']),
      boatA: _parseNullableInt(json[_AisJsonKeys.msg21BoatA] ?? json['boatA']),
      boatB: _parseNullableInt(json[_AisJsonKeys.msg21BoatB] ?? json['boatB']),
      boatC: _parseNullableInt(json[_AisJsonKeys.msg21BoatC] ?? json['boatC']),
      boatD: _parseNullableInt(json[_AisJsonKeys.msg21BoatD] ?? json['boatD']),
    );
  }

  factory AisTargetModel.fromEntity(AisTargetEntity entity) {
    return AisTargetModel(
      mmsi: entity.mmsi,
      type: entity.type,
      latitude: entity.latitude,
      longitude: entity.longitude,
      updatedAt: entity.updatedAt,
      name: entity.name,
      mmsiType: entity.mmsiType,
      vesselType: entity.vesselType,
      utcTime: entity.utcTime,
      localTime: entity.localTime,
      receivedTime: entity.receivedTime,
      desMmsi: entity.desMmsi,
      voltage: entity.voltage,
      current: entity.current,
      lightStatus: entity.lightStatus,
      aidType: entity.aidType,
      boatA: entity.boatA,
      boatB: entity.boatB,
      boatC: entity.boatC,
      boatD: entity.boatD,
    );
  }

  static String? _parseLightStatus(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return switch (value.toInt()) {
        0 => 'NO LIGHT',
        1 => 'ON',
        2 => 'OFF',
        3 => 'ERROR',
        final code => code.toString(),
      };
    }
    final str = _parseNullableString(value);
    if (str == null) return null;
    final asInt = int.tryParse(str);
    if (asInt != null) {
      return _parseLightStatus(asInt);
    }
    return str;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty) return null;
    final lower = trimmed.toLowerCase();
    if (lower == 'null' || lower == 'undefined') return null;
    return trimmed;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'\(V\)|\(A\)|V|A', caseSensitive: false), '')
        .trim();
    return double.tryParse(cleaned);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is int) {
      final ms = value < 10000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.now();

    // Chuẩn hóa chuỗi ISO có >6 chữ số thập phân (vd .NET .4372736+07:00) về 6 chữ số
    final normalizedIso = raw.replaceFirstMapped(
      RegExp(r'\.(\d{6})\d+'),
      (m) => '.${m.group(1)}',
    );
    final iso = DateTime.tryParse(normalizedIso);
    if (iso != null) return iso;

    final parts = raw.split(':');
    if (parts.length == 3) {
      final hh = int.tryParse(parts[0]);
      final mm = int.tryParse(parts[1]);
      final ss = int.tryParse(parts[2]);
      if (hh != null && mm != null && ss != null) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hh, mm, ss);
      }
    }

    return DateTime.now();
  }
}
