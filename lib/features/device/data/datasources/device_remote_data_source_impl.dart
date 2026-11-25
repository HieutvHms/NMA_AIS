import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/device_entity.dart';
import '../models/device_model.dart';
import 'device_remote_datasource.dart';

class DeviceRemoteDataSourceImpl extends BaseRemoteDataSource
    implements DeviceRemoteDataSource {
  DeviceRemoteDataSourceImpl(super.dio);

  Future<dynamic> _safeGet(String url) async {
    try {
      final response = await get(url);
      if (response is Map<String, dynamic> && response['success'] == false) {
        final message = response['message']?.toString().trim();
        throw ServerException(
          message: (message != null && message.isNotEmpty)
              ? message
              : 'Không thể tải danh sách thiết bị.',
        );
      }
      return response;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map &&
          data['message'] != null &&
          data['message'].toString().trim().isNotEmpty) {
        throw ServerException(
          message: data['message'].toString().trim(),
          statusCode: e.response?.statusCode,
        );
      } else if (data is String && data.trim().isNotEmpty) {
        throw ServerException(
          message: data.trim(),
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<DeviceModel>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  }) async {
    final response = await _safeGet(AppConfig.deviceStatusUrl);

    if (response is! Map<String, dynamic>) {
      return [];
    }

    final data = response['data'];
    final rawList = data is Map<String, dynamic> ? data['devices'] : data;
    if (rawList is! List) {
      return [];
    }

    var devices = rawList
        .whereType<Map<String, dynamic>>()
        .map(DeviceModel.fromJson)
        .toList();

    if (statusFilter != null) {
      devices = devices.where((e) => e.status == statusFilter).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      devices = devices.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.mmsi.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    return devices;
  }
}
