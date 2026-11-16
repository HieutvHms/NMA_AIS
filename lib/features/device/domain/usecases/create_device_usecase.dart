import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class CreateDeviceUseCase {
  final DeviceRepository repository;

  CreateDeviceUseCase(this.repository);

  Future<DeviceEntity> call(DeviceEntity device) {
    return repository.createDevice(device);
  }
}
