import '../entities/managed_device_entity.dart';

abstract class DeviceManagementRepository {
  Future<List<ManagedDeviceEntity>> getManagedDevices({
    String? query,
    ManagedDeviceStatus? statusFilter,
  });

  Future<ManagedDeviceEntity> createManagedDevice(ManagedDeviceEntity device);

  Future<ManagedDeviceEntity> updateManagedDevice(ManagedDeviceEntity device);

  Future<void> deleteManagedDevice(String imei);
}

