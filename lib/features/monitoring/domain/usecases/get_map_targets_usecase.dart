import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';
import '../entities/map_bounds_entity.dart';
import '../repositories/map_repository.dart';

/// UseCase tải danh sách đối tượng AIS trong vùng nhìn bản đồ.
class GetMapTargetsUseCase {
  final MapRepository _repository;

  const GetMapTargetsUseCase(this._repository);

  Future<List<AisTargetEntity>> call(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  }) {
    return _repository.getTargetsInBounds(bounds, cancelToken: cancelToken);
  }
}
