import '../models/vessel_model.dart';

class MonitoringRepository {
  final List<VesselModel> _mockData = [
    VesselModel(
      mmsi: '574001230',
      name: 'PACIFIC STAR 01',
      isBuoy: false,
      latitude: 20.8449,
      longitude: 106.6881,
      speed: 11.4,
      course: 145.0,
      udpPort: 5001,
      receivedTime: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    VesselModel(
      mmsi: '995741010',
      name: 'BUOY HPL-01',
      isBuoy: true,
      atonType: 'Cardinal North',
      latitude: 20.8120,
      longitude: 106.7105,
      udpPort: 5001,
      receivedTime: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    VesselModel(
      mmsi: '574009888',
      name: 'VIETSHIP 09',
      isBuoy: false,
      latitude: 10.3459,
      longitude: 107.0843,
      speed: 8.2,
      course: 210.0,
      udpPort: 5002,
      receivedTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  Future<List<VesselModel>> getMonitoredObjects({
    required List<int> allowedPorts,
    int? selectedPort,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.where((item) {
      if (!allowedPorts.contains(item.udpPort)) return false;
      if (selectedPort != null && item.udpPort != selectedPort) return false;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        return item.mmsi.toLowerCase().contains(q) ||
            item.name.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }
}

