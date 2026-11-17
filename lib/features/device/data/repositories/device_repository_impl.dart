import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DeviceEntity>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  }) {
    return remoteDataSource.getDevices(
      query: query,
      statusFilter: statusFilter,
    );
  }

  @override
  Future<DeviceEntity> getDeviceByImei(String imei) {
    return remoteDataSource.getDeviceByImei(imei);
  }

  @override
  Future<DeviceEntity> createDevice(DeviceEntity device) {
    final model = DeviceModel(
      imei: device.imei,
      stationName: device.stationName,
      simSerial: device.simSerial,
      aisPort: device.aisPort,
      secondaryUdpPort: device.secondaryUdpPort,
      aisModuleType: device.aisModuleType,
      status: device.status,
      signalStrength: device.signalStrength > 0 ? device.signalStrength : 25,
      lastMessageTime: device.lastMessageTime ?? DateTime.now(),
      lastAisTime: device.lastAisTime ?? DateTime(2000, 1, 1),
      updatedAt: DateTime.now(),
    );
    return remoteDataSource.createDevice(model);
  }

  @override
  Future<DeviceEntity> updateDevice(DeviceEntity device) async {
    final existing = await remoteDataSource.getDeviceByImei(device.imei);
    final updated = existing.copyWith(
      stationName: device.stationName,
      aisPort: device.aisPort,
      simSerial: device.simSerial,
      secondaryUdpPort: device.secondaryUdpPort,
      aisModuleType: device.aisModuleType,
      updatedAt: DateTime.now(),
    );
    return remoteDataSource.updateDevice(updated);
  }

  @override
  Future<void> deleteDevice(String imei) {
    return remoteDataSource.deleteDevice(imei);
  }
}
