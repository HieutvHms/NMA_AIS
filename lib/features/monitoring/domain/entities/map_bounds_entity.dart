import 'package:equatable/equatable.dart';

/// Vùng nhìn giới hạn trên bản đồ (Bounding Box) dùng để truy vấn theo khung nhìn.
class MapBoundsEntity extends Equatable {
  final double minLat;
  final double minLng;
  final double maxLat;
  final double maxLng;

  const MapBoundsEntity({
    required this.minLat,
    required this.minLng,
    required this.maxLat,
    required this.maxLng,
  });

  /// Kiểm tra một tọa độ có nằm trong vùng nhìn hiện tại hay không.
  bool contains(double latitude, double longitude) {
    final inLat = latitude >= minLat && latitude <= maxLat;
    if (!inLat) return false;

    // Xử lý cả trường hợp khung nhìn vượt qua kinh tuyến đổi ngày (180/-180)
    if (minLng <= maxLng) {
      return longitude >= minLng && longitude <= maxLng;
    }
    return longitude >= minLng || longitude <= maxLng;
  }

  @override
  List<Object?> get props => [minLat, minLng, maxLat, maxLng];
}
