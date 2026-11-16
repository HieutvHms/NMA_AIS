import 'package:equatable/equatable.dart';

class RoutePoint extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

class RouteState extends Equatable {
  final String mmsi;
  final List<RoutePoint> points;
  final bool isLoading;

  const RouteState({
    this.mmsi = '',
    this.points = const [],
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [mmsi, points, isLoading];
}

