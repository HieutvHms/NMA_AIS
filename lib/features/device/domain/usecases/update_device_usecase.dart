import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class UpdateDeviceUseCase {
  final DeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  Future<DeviceEntity> call(DeviceEntity device) {
    return repository.updateDevice(device);
  }
}
