import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';
import '../entities/map_bounds_entity.dart';

abstract class MapRepository {
  Future<List<AisTargetEntity>> getTargetsInBounds(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  });

  /// Lấy toàn bộ danh sách đối tượng AIS mà user hiện tại được phép xem.
  Future<List<AisTargetEntity>> getAllTargets({CancelToken? cancelToken});

  Future<AisTargetEntity?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  });
}
