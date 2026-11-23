import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DeviceEntity>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  }) {
    return remoteDataSource.getDevices(
      query: query,
      statusFilter: statusFilter,
    );
  }
}
