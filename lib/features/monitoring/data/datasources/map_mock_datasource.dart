import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ais_type_mapper.dart';
import '../../domain/entities/map_bounds_entity.dart';
import '../models/ais_target_model.dart';
import 'map_remote_datasource.dart';

/// Nguồn dữ liệu giả lập ~2.000 đối tượng AIS trên vùng biển Việt Nam (lat 8–21, lng 104–112).
/// Dùng để kiểm thử UI, clustering, tìm kiếm MMSI và hiệu năng cập nhật 10s ngay khi chưa có API.
class MapMockDataSource implements MapRemoteDataSource {
  final int targetCount;
  final math.Random _random = math.Random(2026);

  late final List<AisTargetModel> _targets;
  final Map<String, int> _indexByMmsi = {};
  DateTime _lastSimulationTick = DateTime.now();

  MapMockDataSource({this.targetCount = AppConstants.mockAisTargetCount}) {
    _targets = _generateInitialTargets(targetCount);
    for (var i = 0; i < _targets.length; i++) {
      _indexByMmsi[_targets[i].mmsi] = i;
    }
  }

  @override
  Future<List<AisTargetModel>> getTargetsInBounds(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  }) async {
    await _simulateNetworkDelay(cancelToken);
    _advanceVesselPositionsIfNeeded();

    // Lọc các đối tượng nằm trong vùng nhìn hiện tại (giống hành vi API bounding box)
    return _targets
        .where((item) => bounds.contains(item.latitude, item.longitude))
        .toList(growable: false);
  }

  @override
  Future<List<AisTargetModel>> getAllTargets({CancelToken? cancelToken}) async {
    await _simulateNetworkDelay(cancelToken, milliseconds: 80);
    _advanceVesselPositionsIfNeeded();
    return List<AisTargetModel>.unmodifiable(_targets);
  }

  @override
  Future<AisTargetModel?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  }) async {
    await _simulateNetworkDelay(cancelToken, milliseconds: 80);
    _advanceVesselPositionsIfNeeded();

    final normalized = mmsi.trim();
    final exactIndex = _indexByMmsi[normalized];
    if (exactIndex != null) {
      return _targets[exactIndex];
    }

    // Hỗ trợ tìm khớp chuỗi con nếu người dùng nhập MMSI gần đúng
    for (final target in _targets) {
      if (target.mmsi.contains(normalized)) {
        return target;
      }
    }
    return null;
  }

  /// Giả lập độ trễ mạng ngắn và hỗ trợ hủy request qua [CancelToken] giống Dio thật.
  Future<void> _simulateNetworkDelay(
    CancelToken? cancelToken, {
    int milliseconds = 120,
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      throw DioException.requestCancelled(
        requestOptions: RequestOptions(path: '/mock/ais/targets'),
        reason: 'Cancelled before mock execution',
      );
    }

    final completer = Completer<void>();
    final timer = Timer(Duration(milliseconds: milliseconds), () {
      if (!completer.isCompleted) completer.complete();
    });

    cancelToken?.whenCancel.then((_) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          DioException.requestCancelled(
            requestOptions: RequestOptions(path: '/mock/ais/targets'),
            reason: 'Cancelled during mock execution',
          ),
        );
      }
    });

    await completer.future;
  }

  /// Mỗi chu kỳ ~10 giây, dịch chuyển nhẹ ~18% tàu thuyền
  /// để kiểm tra cơ chế chỉ cập nhật các marker thay đổi mà không vẽ lại toàn bộ.
  void _advanceVesselPositionsIfNeeded() {
    final now = DateTime.now();
    if (now.difference(_lastSimulationTick).inSeconds < 8) return;
    _lastSimulationTick = now;

    for (var i = 0; i < _targets.length; i++) {
      final current = _targets[i];
      // Trạm gốc & Phao AtoN đứng cố định
      if (AisTypeMapper.isStationOrAton(current.type)) continue;

      // Chỉ ~18% tàu có bản tin mới trong mỗi nhịp 10s
      if (_random.nextDouble() > 0.18) continue;

      final rad = _random.nextDouble() * 2 * math.pi;
      const step = 0.008; // ~0.9 km mỗi lần cập nhật

      final nextLat = (current.latitude + math.cos(rad) * step).clamp(
        8.0,
        21.0,
      );
      final nextLng = (current.longitude + math.sin(rad) * step).clamp(
        104.0,
        112.0,
      );

      _targets[i] = AisTargetModel(
        mmsi: current.mmsi,
        type: current.type,
        latitude: nextLat,
        longitude: nextLng,
        updatedAt: now,
      );
    }
  }

  /// Sinh danh sách ~2.000 đối tượng phân bố dọc các vùng biển thực tế của Việt Nam
  /// trong khung [lat 8..21, lng 104..112] để không bị rơi sâu vào đất liền.
  List<AisTargetModel> _generateInitialTargets(int count) {
    const vesselTypes = [1, 1, 1, 3, 18, 18, 24];
    final now = DateTime.now();
    final list = <AisTargetModel>[];

    // Các dải tọa độ đại diện cho vùng biển Việt Nam (latMin, latMax, lngMin, lngMax)
    const seaZones = <(double, double, double, double)>[
      (
        18.0,
        21.0,
        106.6,
        109.5,
      ), // Vịnh Bắc Bộ (Hải Phòng, Quảng Ninh -> Hà Tĩnh)
      (15.5, 18.0, 107.6, 111.8), // Biển Bắc Trung Bộ & quần đảo Hoàng Sa
      (12.0, 15.5, 109.2, 112.0), // Biển Nam Trung Bộ (Đà Nẵng -> Khánh Hòa)
      (9.5, 12.0, 107.0, 112.0), // Vũng Tàu - Bình Thuận - Trường Sa
      (
        8.0,
        10.4,
        104.0,
        108.8,
      ), // Cà Mau - Kiên Giang - Vịnh Thái Lan - Côn Đảo
    ];

    // Đường bờ biển thực tế từ Bắc xuống Nam (Quảng Ninh -> Kiên Giang) để rải 50 trạm/đèn biển
    const coastalPath = <(double, double)>[
      (21.46, 107.97), // Móng Cái, Quảng Ninh
      (21.02, 107.42), // Cẩm Phả / Vịnh Bái Tử Long
      (20.85, 106.82), // Hải Phòng / Cát Hải
      (20.45, 106.62), // Thái Bình / Nam Định
      (19.78, 105.92), // Sầm Sơn, Thanh Hóa
      (19.12, 105.78), // Nghi Sơn / Diễn Châu
      (18.78, 105.75), // Cửa Lò, Nghệ An
      (18.18, 106.42), // Vũng Áng, Hà Tĩnh
      (17.48, 106.64), // Đồng Hới, Quảng Bình
      (16.90, 107.20), // Cửa Việt, Quảng Trị
      (16.57, 107.65), // Thuận An, Huế
      (16.12, 108.28), // Sơn Trà, Đà Nẵng
      (15.58, 108.62), // Tam Kỳ / Chu Lai, Quảng Nam
      (15.15, 108.92), // Dung Quất / Sa Kỳ, Quảng Ngãi
      (14.12, 109.22), // Đề Gi, Bình Định
      (13.76, 109.28), // Quy Nhơn, Bình Định
      (13.10, 109.35), // Tuy Hòa, Phú Yên
      (12.24, 109.23), // Nha Trang, Khánh Hòa
      (11.88, 109.24), // Cam Ranh, Khánh Hòa
      (11.55, 109.06), // Phan Rang, Ninh Thuận
      (10.92, 108.28), // Mũi Né / Phan Thiết, Bình Thuận
      (10.67, 107.82), // La Gi, Bình Thuận
      (10.34, 107.08), // Vũng Tàu
      (10.37, 106.95), // Cần Giờ, TP.HCM
      (10.02, 106.78), // Bến Tre / Trà Vinh
      (9.52, 106.25), // Trần Đề, Sóc Trăng
      (9.18, 105.72), // Bạc Liêu
      (8.60, 104.78), // Đất Mũi, Cà Mau
      (9.45, 104.82), // Sông Đốc / U Minh, Cà Mau
      (10.00, 105.05), // Rạch Giá, Kiên Giang
      (10.38, 104.48), // Hà Tiên, Kiên Giang
      (10.22, 103.96), // Phú Quốc, Kiên Giang
    ];

    final stationTotal = (count / 40).ceil();
    var stationIndex = 0;

    for (var i = 0; i < count; i++) {
      // Giữ khoảng 50 Trạm gốc (Type 4) & Phao AtoN (Type 21) rải đều ven biển Bắc -> Nam
      final isStationOrAton = i % 40 == 0;
      final int type;
      final String mmsi;
      final double lat;
      final double lng;

      if (isStationOrAton) {
        final t = stationTotal > 1 ? stationIndex / (stationTotal - 1) : 0.0;
        final scaled = t * (coastalPath.length - 1);
        final seg = scaled.floor().clamp(0, coastalPath.length - 2);
        final frac = scaled - seg;
        final p0 = coastalPath[seg];
        final p1 = coastalPath[seg + 1];
        lat =
            p0.$1 +
            (p1.$1 - p0.$1) * frac +
            (_random.nextDouble() - 0.5) * 0.04;
        lng =
            p0.$2 +
            (p1.$2 - p0.$2) * frac +
            (_random.nextDouble() - 0.5) * 0.04;
        stationIndex++;

        type = (i % 80 == 0) ? 4 : 21;
        // MMSI AtoN chuẩn thường bắt đầu bằng 99574xxxx, trạm bờ 00574xxxx
        final prefix = type == 4 ? '00574' : '99574';
        mmsi = '$prefix${(1000 + i).toString().padLeft(4, '0')}';
      } else {
        final zone = seaZones[i % seaZones.length];
        lat = zone.$1 + _random.nextDouble() * (zone.$2 - zone.$1);
        lng = zone.$3 + _random.nextDouble() * (zone.$4 - zone.$3);
        type = vesselTypes[i % vesselTypes.length];
        // MMSI tàu Việt Nam bắt đầu bằng MID 574
        mmsi = '574${(100000 + i).toString().padLeft(6, '0')}';
      }

      final secondsAgo = _random.nextInt(120);
      list.add(
        AisTargetModel(
          mmsi: mmsi,
          type: type,
          latitude: double.parse(lat.toStringAsFixed(6)),
          longitude: double.parse(lng.toStringAsFixed(6)),
          updatedAt: now.subtract(Duration(seconds: secondsAgo)),
        ),
      );
    }

    return list;
  }
}
