import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';

abstract class MapRepository {
  /// Lấy toàn bộ danh sách đối tượng AIS mà user hiện tại được phép xem.
  Future<List<AisTargetEntity>> getAllTargets({
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<AisTargetEntity?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  });
}
