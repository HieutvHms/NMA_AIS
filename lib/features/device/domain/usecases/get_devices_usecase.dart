import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class GetDevicesUseCase {
  final DeviceRepository repository;

  GetDevicesUseCase(this.repository);

  Future<List<DeviceEntity>> call({String? query, DeviceStatus? statusFilter}) {
    return repository.getDevices(query: query, statusFilter: statusFilter);
  }
}

