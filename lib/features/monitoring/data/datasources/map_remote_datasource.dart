import 'package:dio/dio.dart';
import '../../domain/entities/map_bounds_entity.dart';
import '../models/ais_target_model.dart';

abstract class MapRemoteDataSource {
  Future<List<AisTargetModel>> getTargetsInBounds(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  });

  /// Lấy toàn bộ danh sách trạm và tàu mà user được phép xem (không lọc theo vùng nhìn).
  Future<List<AisTargetModel>> getAllTargets({CancelToken? cancelToken});

  Future<AisTargetModel?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  });
}
