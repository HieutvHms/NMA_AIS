import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/managed_device_entity.dart';
import '../models/managed_device_model.dart';

abstract class DeviceManagementRemoteDataSource {
  Future<List<ManagedDeviceModel>> getManagedDevices({
    String? query,
    ManagedDeviceStatus? statusFilter,
  });

  Future<ManagedDeviceModel> createManagedDevice(ManagedDeviceModel device);

  Future<ManagedDeviceModel> updateManagedDevice(ManagedDeviceModel device);

  Future<void> deleteManagedDevice(String imei);
}

class DeviceManagementRemoteDataSourceImpl extends BaseRemoteDataSource
    implements DeviceManagementRemoteDataSource {
  final LocalStorage _localStorage;

  DeviceManagementRemoteDataSourceImpl(super.dio, this._localStorage);

  int get _currentUserId {
    final rawUserId = _localStorage.getUserId();
    return int.tryParse(rawUserId ?? '') ?? 0;
  }

  Future<dynamic> _safePost(String url, Map<String, dynamic> body) async {
    try {
      final response = await post(url, data: body);
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
      throw ServerException(
        message: 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ManagedDeviceModel>> getManagedDevices({
    String? query,
    ManagedDeviceStatus? statusFilter,
  }) async {
    final response = await _safePost(AppConfig.deviceQueryUrl, {
      'type': 2,
      'userId': _currentUserId,
    });

    if (response is! Map<String, dynamic>) {
      return [];
    }

    final rawList = response['data'];
    if (rawList is! List) {
      return [];
    }

    var devices = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ManagedDeviceModel.fromJson(item))
        .toList();

    if (statusFilter != null) {
      devices = devices.where((e) => e.status == statusFilter).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      devices = devices.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    return devices;
  }

  @override
  Future<ManagedDeviceModel> createManagedDevice(
    ManagedDeviceModel device,
  ) async {
    final response = await _safePost(AppConfig.deviceUpdateUrl, {
      'type': 1,
      'data': device.toCreatePayload(_currentUserId),
    });

    if (response is Map<String, dynamic> &&
        response['data'] is Map<String, dynamic>) {
      return ManagedDeviceModel.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    }

    return device;
  }

  @override
  Future<ManagedDeviceModel> updateManagedDevice(
    ManagedDeviceModel device,
  ) async {
    final response = await _safePost(AppConfig.deviceUpdateUrl, {
      'type': 2,
      'data': device.toUpdatePayload(_currentUserId),
    });

    if (response is Map<String, dynamic> &&
        response['data'] is Map<String, dynamic>) {
      return ManagedDeviceModel.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    }

    return device;
  }

  @override
  Future<void> deleteManagedDevice(String imei) async {
    await _safePost(AppConfig.deviceUpdateUrl, {
      'type': 3,
      'data': {'imei': imei},
    });
  }
}
