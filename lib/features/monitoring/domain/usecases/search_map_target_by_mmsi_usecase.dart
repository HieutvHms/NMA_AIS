import 'package:dio/dio.dart';
import '../entities/ais_target_entity.dart';
import '../repositories/map_repository.dart';

class SearchMapTargetByMmsiUseCase {
  final MapRepository _repository;

  const SearchMapTargetByMmsiUseCase(this._repository);

  Future<AisTargetEntity?> call(String mmsi, {CancelToken? cancelToken}) {
    final trimmed = mmsi.trim();
    if (trimmed.isEmpty) return Future.value(null);
    return _repository.findTargetByMmsi(trimmed, cancelToken: cancelToken);
  }
}
