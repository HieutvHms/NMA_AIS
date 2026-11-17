import '../entities/managed_device_entity.dart';
import '../repositories/device_management_repository.dart';

class UpdateManagedDeviceUseCase {
  final DeviceManagementRepository repository;

  UpdateManagedDeviceUseCase(this.repository);

  Future<ManagedDeviceEntity> call(ManagedDeviceEntity device) {
    return repository.updateManagedDevice(device);
  }
}

