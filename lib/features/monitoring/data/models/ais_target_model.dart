import '../../domain/entities/ais_target_entity.dart';

class _AisJsonKeys {
  _AisJsonKeys._();

  static const String mmsi = 'mmsi';
  static const String type = 'type';
  static const String altType = 'msgType';
  static const String latitude = 'latitude';
  static const String altLatitude = 'lat';
  static const String longitude = 'longitude';
  static const String altLongitude = 'lng';
  static const String updatedAt = 'updatedAt';
  static const String altTimestamp = 'timestamp';
}

class AisTargetModel extends AisTargetEntity {
  const AisTargetModel({
    required super.mmsi,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.updatedAt,
  });

  factory AisTargetModel.fromJson(Map<String, dynamic> json) {
    final rawType = json[_AisJsonKeys.type] ?? json[_AisJsonKeys.altType];
    final rawLat =
        json[_AisJsonKeys.latitude] ?? json[_AisJsonKeys.altLatitude];
    final rawLng =
        json[_AisJsonKeys.longitude] ?? json[_AisJsonKeys.altLongitude];
    final rawTime =
        json[_AisJsonKeys.updatedAt] ?? json[_AisJsonKeys.altTimestamp];

    return AisTargetModel(
      mmsi: json[_AisJsonKeys.mmsi]?.toString().trim() ?? '',
      type: _parseInt(rawType, fallback: 1),
      latitude: _parseDouble(rawLat) ?? 0.0,
      longitude: _parseDouble(rawLng) ?? 0.0,
      updatedAt: _parseDateTime(rawTime),
    );
  }

  factory AisTargetModel.fromEntity(AisTargetEntity entity) {
    return AisTargetModel(
      mmsi: entity.mmsi,
      type: entity.type,
      latitude: entity.latitude,
      longitude: entity.longitude,
      updatedAt: entity.updatedAt,
    );
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
    return double.tryParse(value.toString());
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is int) {
      final ms = value < 10000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.now();

    final iso = DateTime.tryParse(raw);
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
