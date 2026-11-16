import 'package:equatable/equatable.dart';

class AisConfigModel extends Equatable {
  final String deviceId;
  final String mmsi;

  const AisConfigModel({
    required this.deviceId,
    required this.mmsi,
  });

  @override
  List<Object?> get props => [deviceId, mmsi];
}

