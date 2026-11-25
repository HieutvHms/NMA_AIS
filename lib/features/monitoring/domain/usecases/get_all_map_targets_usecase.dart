import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';
import '../repositories/map_repository.dart';

/// UseCase lấy toàn bộ danh sách trạm và tàu mà người dùng hiện tại được phép xem
/// (không phụ thuộc vào vùng nhìn hiện tại trên bản đồ).
class GetAllMapTargetsUseCase {
  final MapRepository _repository;

  const GetAllMapTargetsUseCase(this._repository);

  Future<List<AisTargetEntity>> call({CancelToken? cancelToken}) {
    return _repository.getAllTargets(cancelToken: cancelToken);
  }
}
