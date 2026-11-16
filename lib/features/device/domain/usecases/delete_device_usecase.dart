import '../repositories/device_repository.dart';

class DeleteDeviceUseCase {
  final DeviceRepository repository;

  DeleteDeviceUseCase(this.repository);

  Future<void> call(String imei) {
    return repository.deleteDevice(imei);
  }
}

