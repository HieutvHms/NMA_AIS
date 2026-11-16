import 'package:equatable/equatable.dart';

class VesselModel extends Equatable {
  final String mmsi;
  final String name;
  final bool isBuoy;
  final String? atonType;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? course;
  final int udpPort;
  final DateTime receivedTime;

  const VesselModel({
    required this.mmsi,
    required this.name,
    required this.isBuoy,
    this.atonType,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.course,
    required this.udpPort,
    required this.receivedTime,
  });

  @override
  List<Object?> get props => [
        mmsi,
        name,
        isBuoy,
        atonType,
        latitude,
        longitude,
        speed,
        course,
        udpPort,
        receivedTime,
      ];
}

