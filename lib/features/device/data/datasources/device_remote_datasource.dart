import '../models/device_model.dart';
import '../../domain/entities/device_entity.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  });
  Future<DeviceModel> getDeviceByImei(String imei);
  Future<DeviceModel> createDevice(DeviceModel device);
  Future<DeviceModel> updateDevice(DeviceModel device);
  Future<void> deleteDevice(String imei);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final List<DeviceModel> _devices = [
    DeviceModel(
      imei: '860123456789012',
      stationName: 'AIS Device 001',
      simSerial: '89840480009494087557',
      aisPort: 6039,
      status: DeviceStatus.online,
      signalStrength: 28, // 85%
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      lastAisTime: DateTime(2026, 11, 14, 14, 30),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 30),
    ),
    DeviceModel(
      imei: '860123456789013',
      stationName: 'AIS Device 002',
      simSerial: '89840480009494087680',
      aisPort: 6026,
      status: DeviceStatus.offline,
      signalStrength: 0,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      lastAisTime: DateTime(2026, 11, 14, 10, 15),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 10, 15),
    ),
    DeviceModel(
      imei: '860123456789014',
      stationName: 'AIS Device 003',
      simSerial: '89840480009343953231',
      aisPort: 6020,
      status: DeviceStatus.online,
      signalStrength: 31,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
      lastAisTime: DateTime(2026, 11, 14, 14, 25),
      aisModuleType: 'AIS AtoN Type 3',
      updatedAt: DateTime(2026, 11, 14, 14, 25),
    ),
    DeviceModel(
      imei: '860123456789015',
      stationName: 'AIS Device 004',
      simSerial: '89840480009762352139',
      aisPort: 6012,
      status: DeviceStatus.online,
      signalStrength: 26,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      lastAisTime: DateTime(2026, 11, 14, 14, 20),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 20),
    ),
    DeviceModel(
      imei: '860123456789016',
      stationName: 'AIS Device 005',
      simSerial: '89840480009343953223',
      aisPort: 6021,
      status: DeviceStatus.offline,
      signalStrength: 14,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      lastAisTime: DateTime(2026, 11, 14, 13, 00),
      aisModuleType: 'AIS Base Station',
      updatedAt: DateTime(2026, 11, 14, 13, 00),
    ),
    DeviceModel(
      imei: '862211074322678',
      stationName: 'DUNG QUẤT',
      simSerial: '89840480009494087557',
      aisPort: 6039,
      status: DeviceStatus.online,
      signalStrength: 29,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 3)),
      lastAisTime: DateTime(2026, 11, 14, 14, 28),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 28),
    ),
    DeviceModel(
      imei: '862211074346420',
      stationName: 'THUẬN AN',
      simSerial: '89840480009494087680',
      aisPort: 6026,
      status: DeviceStatus.offline,
      signalStrength: 0,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      lastAisTime: DateTime(2026, 11, 14, 09, 30),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 09, 30),
    ),
    DeviceModel(
      imei: '862211074323429',
      stationName: 'CỬA GIANH',
      simSerial: '89840480009343953231',
      aisPort: 6020,
      status: DeviceStatus.offline,
      signalStrength: 15,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      lastAisTime: DateTime(2026, 11, 14, 12, 10),
      aisModuleType: 'AIS AtoN Type 3',
      updatedAt: DateTime(2026, 11, 14, 12, 10),
    ),
    DeviceModel(
      imei: '865194061637497',
      stationName: 'MŨI DINH',
      simSerial: '89840480009762352139',
      aisPort: 6018,
      status: DeviceStatus.online,
      signalStrength: 24,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
      lastAisTime: DateTime(2026, 11, 14, 14, 22),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 22),
    ),
    DeviceModel(
      imei: '862211074322884',
      stationName: 'NHẬT LỆ',
      simSerial: '89840480009343953223',
      aisPort: 6021,
      status: DeviceStatus.online,
      signalStrength: 27,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 11)),
      lastAisTime: DateTime(2026, 11, 14, 14, 19),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 19),
    ),
    DeviceModel(
      imei: '862211074336587',
      stationName: 'CHÂN MÂY',
      simSerial: '89840480009494087672',
      aisPort: 6027,
      status: DeviceStatus.online,
      signalStrength: 30,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 14)),
      lastAisTime: DateTime(2026, 11, 14, 14, 16),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 16),
    ),
    DeviceModel(
      imei: '862211074342361',
      stationName: 'CỒN CỎ',
      simSerial: '89840480009343952506',
      aisPort: 6024,
      status: DeviceStatus.online,
      signalStrength: 31,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 18)),
      lastAisTime: DateTime(2026, 11, 14, 14, 12),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 12),
    ),
    DeviceModel(
      imei: '862211074347204',
      stationName: 'CỬA VIỆT',
      simSerial: '89840480009343953207',
      aisPort: 6025,
      status: DeviceStatus.online,
      signalStrength: 25,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 21)),
      lastAisTime: DateTime(2026, 11, 14, 14, 09),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 09),
    ),
    DeviceModel(
      imei: '862211074343427',
      stationName: 'LẠCH GIANG',
      simSerial: '89840480009343953280',
      aisPort: 6010,
      status: DeviceStatus.online,
      signalStrength: 29,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 25)),
      lastAisTime: DateTime(2026, 11, 14, 14, 05),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 05),
    ),
    DeviceModel(
      imei: '862211074344235',
      stationName: 'MŨI RÒN',
      simSerial: '89840480009343953330',
      aisPort: 6018,
      status: DeviceStatus.online,
      signalStrength: 28,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 28)),
      lastAisTime: DateTime(2026, 11, 14, 14, 02),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 14, 02),
    ),
    DeviceModel(
      imei: '862211074344284',
      stationName: 'CỬA HỘI',
      simSerial: '89840480009343953306',
      aisPort: 6015,
      status: DeviceStatus.online,
      signalStrength: 27,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 32)),
      lastAisTime: DateTime(2026, 11, 14, 13, 58),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 13, 58),
    ),
    DeviceModel(
      imei: '862211074346461',
      stationName: 'BA LÀNG AN',
      simSerial: '89840480009494087615',
      aisPort: 6037,
      status: DeviceStatus.online,
      signalStrength: 31,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 35)),
      lastAisTime: DateTime(2026, 11, 14, 13, 55),
      aisModuleType: 'AIS AtoN Type 1',
      updatedAt: DateTime(2026, 11, 14, 13, 55),
    ),
  ];

  @override
  Future<List<DeviceModel>> getDevices({
    String? query,
    DeviceStatus? statusFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var result = List<DeviceModel>.from(_devices);

    if (statusFilter != null) {
      result = result.where((e) => e.status == statusFilter).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((e) {
        return e.stationName.toLowerCase().contains(q) ||
            e.imei.toLowerCase().contains(q) ||
            e.aisPort.toString().contains(q) ||
            e.simSerial.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  @override
  Future<DeviceModel> getDeviceByImei(String imei) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _devices.firstWhere(
      (e) => e.imei == imei,
      orElse: () => throw Exception('Không tìm thấy thiết bị có IMEI $imei'),
    );
  }

  @override
  Future<DeviceModel> createDevice(DeviceModel device) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exists = _devices.any((e) => e.imei == device.imei);
    if (exists) {
      throw Exception(
        'Thiết bị có IMEI ${device.imei} đã tồn tại trong hệ thống',
      );
    }
    _devices.insert(0, device);
    return device;
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel device) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _devices.indexWhere((e) => e.imei == device.imei);
    if (index == -1) {
      throw Exception('Không tìm thấy thiết bị có IMEI ${device.imei}');
    }
    _devices[index] = device;
    return device;
  }

  @override
  Future<void> deleteDevice(String imei) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _devices.removeWhere((e) => e.imei == imei);
  }
}
