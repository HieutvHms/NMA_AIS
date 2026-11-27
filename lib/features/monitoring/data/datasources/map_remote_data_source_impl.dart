import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/ais_target_model.dart';
import 'map_remote_datasource.dart';

class MapRemoteDataSourceImpl extends BaseRemoteDataSource
    implements MapRemoteDataSource {
  List<AisTargetModel>? _clientFilterCache;
  DateTime? _lastFullFetchTime;

  MapRemoteDataSourceImpl(super.dio);

  @override
  Future<List<AisTargetModel>> getAllTargets({
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final cacheTTL =
        AppConstants.mapAutoRefreshInterval - const Duration(seconds: 1);
    final isCacheValid =
        !forceRefresh &&
        _clientFilterCache != null &&
        _lastFullFetchTime != null &&
        now.difference(_lastFullFetchTime!) < cacheTTL;

    if (!isCacheValid) {
      final rawResponse = await get(
        AppConfig.aisDataUrl,
        cancelToken: cancelToken,
      );
      _clientFilterCache = _parseTargetList(rawResponse);
      _lastFullFetchTime = DateTime.now();
    }

    return _clientFilterCache!;
  }

  @override
  Future<AisTargetModel?> findTargetByMmsi(
    String mmsi, {
    CancelToken? cancelToken,
  }) async {
    final trimmed = mmsi.trim();
    if (trimmed.isEmpty) return null;

    final allTargets = await getAllTargets(cancelToken: cancelToken);
    for (final item in allTargets) {
      if (item.mmsi == trimmed) return item;
    }
    for (final item in allTargets) {
      if (item.mmsi.contains(trimmed)) return item;
    }
    return null;
  }

  List<AisTargetModel> _parseTargetList(dynamic rawResponse) {
    final rawList = _extractList(rawResponse);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(AisTargetModel.fromJson)
        .where((item) => item.mmsi.isNotEmpty)
        .toList(growable: false);
  }

  static List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == false) {
        throw ServerException(
          message:
              responseData['message']?.toString() ?? 'Không thể tải dữ liệu AIS',
        );
      }
      final inner = responseData['data'] ?? responseData['items'];
      if (inner is List) return inner;
    }
    return const [];
  }
}
