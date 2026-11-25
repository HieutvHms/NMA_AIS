import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/ais_type_mapper.dart';

/// Bộ nhớ đệm BitmapDescriptor cho toàn bộ icon trên bản đồ AIS.
/// Dùng `BitmapDescriptor.asset` với PNG 64x64 để Google Maps Android cache 1 Bitmap duy nhất,
/// không gửi lặp lại mảng byte PNG qua PlatformChannel.
class AisMarkerIconCache {
  AisMarkerIconCache._();

  static const String _vesselPngAsset = 'assets/icons/map/ship.png';
  static const String _stationPngAsset = 'assets/icons/map/tram_thu.png';

  static BitmapDescriptor? _vesselIcon;
  static BitmapDescriptor? _vesselSelectedIcon;
  static BitmapDescriptor? _stationIcon;
  static BitmapDescriptor? _stationSelectedIcon;
  static Future<void>? _initFuture;

  static bool get isReady =>
      _vesselIcon != null &&
      _vesselSelectedIcon != null &&
      _stationIcon != null &&
      _stationSelectedIcon != null;

  /// Khởi tạo toàn bộ icon một lần duy nhất (an toàn khi gọi đồng thời).
  static Future<void> ensureInitialized() {
    if (isReady) return Future.value();
    return _initFuture ??= _buildAllIcons();
  }

  /// Đặt lại cache nếu cần tải lại icon.
  static Future<void> rebuildCache() {
    _vesselIcon = null;
    _vesselSelectedIcon = null;
    _stationIcon = null;
    _stationSelectedIcon = null;
    _initFuture = null;
    return ensureInitialized();
  }

  /// Lấy icon đã cache theo phân loại đối tượng và trạng thái đang chọn.
  static BitmapDescriptor iconFor({
    required int type,
    required bool isSelected,
  }) {
    final kind = AisTypeMapper.resolveKind(type);
    if (kind == AisTargetKind.stationOrAton) {
      return (isSelected ? _stationSelectedIcon : _stationIcon) ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    return (isSelected ? _vesselSelectedIcon : _vesselIcon) ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  static Future<void> _buildAllIcons() async {
    final results = await Future.wait<BitmapDescriptor>([
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(22, 22)),
        _vesselPngAsset,
        width: 22,
        height: 22,
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(34, 34)),
        _vesselPngAsset,
        width: 34,
        height: 34,
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(28, 28)),
        _stationPngAsset,
        width: 28,
        height: 28,
      ),
      BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        _stationPngAsset,
        width: 40,
        height: 40,
      ),
    ]);

    _vesselIcon = results[0];
    _vesselSelectedIcon = results[1];
    _stationIcon = results[2];
    _stationSelectedIcon = results[3];
  }
}
