import '../../domain/entities/device_entity.dart';
import '../models/device_model.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  });
}
