import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';
import '../repositories/map_repository.dart';

class GetAllMapTargetsUseCase {
  final MapRepository _repository;

  const GetAllMapTargetsUseCase(this._repository);

  Future<List<AisTargetEntity>> call({CancelToken? cancelToken}) {
    return _repository.getAllTargets(cancelToken: cancelToken);
  }
}
