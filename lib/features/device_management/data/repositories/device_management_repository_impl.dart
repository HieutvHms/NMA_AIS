import '../../domain/entities/managed_device_entity.dart';
import '../../domain/repositories/device_management_repository.dart';
import '../datasources/device_management_remote_datasource.dart';
import '../models/managed_device_model.dart';

class DeviceManagementRepositoryImpl implements DeviceManagementRepository {
  final DeviceManagementRemoteDataSource remoteDataSource;

  DeviceManagementRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ManagedDeviceEntity>> getManagedDevices({
    String? query,
    ManagedDeviceStatus? statusFilter,
  }) {
    return remoteDataSource.getManagedDevices(
      query: query,
      statusFilter: statusFilter,
    );
  }

  @override
  Future<ManagedDeviceEntity> createManagedDevice(ManagedDeviceEntity device) {
    final model = ManagedDeviceModel(
      imei: device.imei,
      stationName: device.stationName,
      simSerial: device.simSerial,
      mmsi: device.mmsi,
      aisPort: device.aisPort,
      secondaryUdpPort: device.secondaryUdpPort,
      aisModuleType: device.aisModuleType,
      status: device.status,
      signalStrength: device.signalStrength > 0 ? device.signalStrength : 26,
      lastMessageTime: device.lastMessageTime ?? DateTime.now(),
      lastAisTime: device.lastAisTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return remoteDataSource.createManagedDevice(model);
  }

  @override
  Future<ManagedDeviceEntity> updateManagedDevice(
    ManagedDeviceEntity device,
  ) async {
    final model = ManagedDeviceModel.fromEntity(
      device,
    ).copyWith(updatedAt: DateTime.now());
    return remoteDataSource.updateManagedDevice(model);
  }

  @override
  Future<void> deleteManagedDevice(String imei) {
    return remoteDataSource.deleteManagedDevice(imei);
  }
}

