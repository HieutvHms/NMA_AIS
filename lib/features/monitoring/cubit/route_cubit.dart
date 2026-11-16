import 'package:flutter_bloc/flutter_bloc.dart';
import 'route_state.dart';

class RouteCubit extends Cubit<RouteState> {
  RouteCubit() : super(const RouteState());

  Future<void> loadRoute(String mmsi) async {
    emit(RouteState(mmsi: mmsi, isLoading: true));
    await Future.delayed(const Duration(milliseconds: 400));
    emit(RouteState(
      mmsi: mmsi,
      isLoading: false,
      points: [
        RoutePoint(
          latitude: 20.8400,
          longitude: 106.6800,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RoutePoint(
          latitude: 20.8449,
          longitude: 106.6881,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }
}

