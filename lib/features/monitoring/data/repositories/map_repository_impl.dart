import 'package:dio/dio.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/entities/map_bounds_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource _remoteDataSource;

  const MapRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AisTargetEntity>> getTargetsInBounds(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  }) {
    return _remoteDataSource.getTargetsInBounds(
      bounds,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<AisTargetEntity>> getAllTargets({CancelToken? cancelToken}) {
    return _remoteDataSource.getAllTargets(cancelToken: cancelToken);
  }

  @override
  Future<AisTargetEntity?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  }) {
    return _remoteDataSource.findTargetByMmsi(
      mmsi,
      cancelToken: cancelToken,
    );
  }
}
