import '../models/ais_config_model.dart';

class AisConfigRepository {
  Future<AisConfigModel> getAisConfig(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AisConfigModel(deviceId: deviceId, mmsi: '995741001');
  }

  Future<AisConfigModel> updateMmsi({
    required String deviceId,
    required String mmsi,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AisConfigModel(deviceId: deviceId, mmsi: mmsi);
  }
}

