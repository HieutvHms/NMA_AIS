import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/map_bounds_entity.dart';
import '../models/ais_target_model.dart';
import 'map_remote_datasource.dart';

/// Tập trung cấu hình gọi API thật cho bản đồ AIS tại MỘT chỗ duy nhất.
/// TODO: Điền chính xác tên tham số và cấu trúc response khi Backend cung cấp API.
class _MapApiSpec {
  _MapApiSpec._();

  /// Đổi thành `false` nếu Backend CHƯA hỗ trợ lọc theo bounding box
  /// (khi đó DataSource sẽ tự động cache ngắn hạn và lọc bounding box phía client).
  static const bool backendSupportsBoundingBox = true;

  /// Đổi thành `true` nếu Backend dùng `POST` thay vì `GET` (như các API `/device/query`).
  static const bool usePostMethod = false;

  // Tên tham số gửi lên Backend
  static const String paramMinLat = 'minLat';
  static const String paramMinLng = 'minLng';
  static const String paramMaxLat = 'maxLat';
  static const String paramMaxLng = 'maxLng';
  static const String paramMmsi = 'mmsi';

  /// Trích xuất mảng JSON từ response của Backend (hỗ trợ cả `{ data: [...] }` lẫn `[...]`).
  static List<dynamic> extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final inner = responseData['data'] ?? responseData['items'];
      if (inner is List) return inner;
    }
    return const [];
  }
}

class MapRemoteDataSourceImpl extends BaseRemoteDataSource
    implements MapRemoteDataSource {
  /// Bộ nhớ đệm ngắn hạn dùng cho phương án fallback lọc phía client
  /// khi Backend trả về toàn bộ ~1.700+ đối tượng mà không lọc theo tọa độ.
  List<AisTargetModel>? _clientFilterCache;
  DateTime? _lastFullFetchTime;

  MapRemoteDataSourceImpl(super.dio);

  @override
  Future<List<AisTargetModel>> getTargetsInBounds(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  }) async {
    if (!_MapApiSpec.backendSupportsBoundingBox) {
      return _getWithClientSideFiltering(bounds, cancelToken: cancelToken);
    }

    final params = <String, dynamic>{
      _MapApiSpec.paramMinLat: bounds.minLat,
      _MapApiSpec.paramMinLng: bounds.minLng,
      _MapApiSpec.paramMaxLat: bounds.maxLat,
      _MapApiSpec.paramMaxLng: bounds.maxLng,
    };

    final rawResponse = _MapApiSpec.usePostMethod
        ? await post(
            AppConfig.mapTargetsUrl,
            data: params,
            cancelToken: cancelToken,
          )
        : await get(
            AppConfig.mapTargetsUrl,
            queryParameters: params,
            cancelToken: cancelToken,
          );

    final list = _parseTargetList(rawResponse);

    // Lọc an toàn thêm một lớp phía client phòng trường hợp API trả dư ngoài rìa khung nhìn
    return list
        .where((item) => bounds.contains(item.latitude, item.longitude))
        .toList(growable: false);
  }

  @override
  Future<List<AisTargetModel>> getAllTargets({CancelToken? cancelToken}) async {
    final now = DateTime.now();
    final cacheTTL =
        AppConstants.mapAutoRefreshInterval - const Duration(seconds: 1);
    final isCacheValid =
        _clientFilterCache != null &&
        _lastFullFetchTime != null &&
        now.difference(_lastFullFetchTime!) < cacheTTL;

    if (!isCacheValid) {
      final rawResponse = _MapApiSpec.usePostMethod
          ? await post(AppConfig.mapTargetsUrl, cancelToken: cancelToken)
          : await get(AppConfig.mapTargetsUrl, cancelToken: cancelToken);
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

    // Nếu đang có sẵn cache phía client thì tìm ngay lập tức O(n) không tốn mạng
    if (_clientFilterCache != null) {
      for (final item in _clientFilterCache!) {
        if (item.mmsi == trimmed) return item;
      }
    }

    // TODO: Chỉnh lại endpoint/tham số tìm kiếm theo MMSI nếu Backend tách riêng API
    final params = <String, dynamic>{_MapApiSpec.paramMmsi: trimmed};
    final rawResponse = _MapApiSpec.usePostMethod
        ? await post(
            AppConfig.mapTargetsUrl,
            data: params,
            cancelToken: cancelToken,
          )
        : await get(
            AppConfig.mapTargetsUrl,
            queryParameters: params,
            cancelToken: cancelToken,
          );

    if (rawResponse is Map<String, dynamic> &&
        rawResponse['data'] is Map<String, dynamic>) {
      return AisTargetModel.fromJson(
        rawResponse['data'] as Map<String, dynamic>,
      );
    }

    final list = _parseTargetList(rawResponse);
    for (final item in list) {
      if (item.mmsi == trimmed || item.mmsi.contains(trimmed)) {
        return item;
      }
    }
    return null;
  }

  /// Phương án dự phòng khi Backend chưa có API theo bounding box:
  /// Tải toàn bộ danh sách tối đa mỗi ~9 giây/lần, còn thao tác kéo/zoom bản đồ
  /// sẽ lọc trực tiếp trên RAM (< 2ms cho 2.000 đối tượng).
  Future<List<AisTargetModel>> _getWithClientSideFiltering(
    MapBoundsEntity bounds, {
    CancelToken? cancelToken,
  }) async {
    final now = DateTime.now();
    final cacheTTL =
        AppConstants.mapAutoRefreshInterval - const Duration(seconds: 1);
    final isCacheValid =
        _clientFilterCache != null &&
        _lastFullFetchTime != null &&
        now.difference(_lastFullFetchTime!) < cacheTTL;

    if (!isCacheValid) {
      final rawResponse = _MapApiSpec.usePostMethod
          ? await post(AppConfig.mapTargetsUrl, cancelToken: cancelToken)
          : await get(AppConfig.mapTargetsUrl, cancelToken: cancelToken);
      _clientFilterCache = _parseTargetList(rawResponse);
      _lastFullFetchTime = DateTime.now();
    }

    return _clientFilterCache!
        .where((item) => bounds.contains(item.latitude, item.longitude))
        .toList(growable: false);
  }

  List<AisTargetModel> _parseTargetList(dynamic rawResponse) {
    final rawList = _MapApiSpec.extractList(rawResponse);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(AisTargetModel.fromJson)
        .where((item) => item.mmsi.isNotEmpty)
        .toList(growable: false);
  }
}
