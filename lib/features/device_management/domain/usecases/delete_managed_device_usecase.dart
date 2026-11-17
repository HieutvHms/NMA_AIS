import '../repositories/device_management_repository.dart';

class DeleteManagedDeviceUseCase {
  final DeviceManagementRepository repository;

  DeleteManagedDeviceUseCase(this.repository);

  Future<void> call(String imei) {
    return repository.deleteManagedDevice(imei);
  }
}

