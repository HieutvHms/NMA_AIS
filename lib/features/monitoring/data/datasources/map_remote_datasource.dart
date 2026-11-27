import 'package:dio/dio.dart';
import '../models/ais_target_model.dart';

abstract class MapRemoteDataSource {
  /// Lấy toàn bộ danh sách trạm và tàu mà user được phép xem.
  Future<List<AisTargetModel>> getAllTargets({
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });

  Future<AisTargetModel?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  });
}
