import '../entities/device_entity.dart';

abstract class DeviceRepository {
  Future<List<DeviceEntity>> getDevices({String? query, DeviceStatus? statusFilter});
  Future<DeviceEntity> getDeviceByImei(String imei);
  Future<DeviceEntity> createDevice(DeviceEntity device);
  Future<DeviceEntity> updateDevice(DeviceEntity device);
  Future<void> deleteDevice(String imei);
}
