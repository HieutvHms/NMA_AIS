import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class GetDeviceDetailUseCase {
  final DeviceRepository repository;

  GetDeviceDetailUseCase(this.repository);

  Future<DeviceEntity> call(String imei) {
    return repository.getDeviceByImei(imei);
  }
}

