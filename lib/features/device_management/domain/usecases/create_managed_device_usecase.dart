import '../entities/managed_device_entity.dart';
import '../repositories/device_management_repository.dart';

class CreateManagedDeviceUseCase {
  final DeviceManagementRepository repository;

  CreateManagedDeviceUseCase(this.repository);

  Future<ManagedDeviceEntity> call(ManagedDeviceEntity device) {
    return repository.createManagedDevice(device);
  }
}

