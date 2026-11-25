import 'package:equatable/equatable.dart';
import 'ais_type_mapper.dart';

/// Thực thể đối tượng AIS hiển thị trên bản đồ giám sát.
class AisTargetEntity extends Equatable {
  final String mmsi;
  final int type;
  final double latitude;
  final double longitude;

  /// Thời điểm cập nhật bản tin gần nhất.
  final DateTime updatedAt;

  const AisTargetEntity({
    required this.mmsi,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  /// Phân nhóm đối tượng (Trạm/Phao hoặc Tàu) thông qua AisTypeMapper.
  AisTargetKind get kind => AisTypeMapper.resolveKind(type);

  bool get isStationOrAton => AisTypeMapper.isStationOrAton(type);

  /// Định dạng thời gian cập nhật cuối theo chuẩn `HH:mm:ss`.
  String get formattedTime {
    final local = updatedAt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  AisTargetEntity copyWith({
    String? mmsi,
    int? type,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
  }) {
    return AisTargetEntity(
      mmsi: mmsi ?? this.mmsi,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [mmsi, type, latitude, longitude, updatedAt];
}
