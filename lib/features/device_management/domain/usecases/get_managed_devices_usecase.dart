import '../entities/managed_device_entity.dart';
import '../repositories/device_management_repository.dart';

class GetManagedDevicesUseCase {
  final DeviceManagementRepository repository;

  GetManagedDevicesUseCase(this.repository);

  Future<List<ManagedDeviceEntity>> call({
    String? query,
    ManagedDeviceStatus? statusFilter,
  }) {
    return repository.getManagedDevices(
      query: query,
      statusFilter: statusFilter,
    );
  }
}

