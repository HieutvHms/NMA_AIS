import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/monitoring_repository.dart';
import 'monitoring_state.dart';

class MonitoringCubit extends Cubit<MonitoringState> {
  final MonitoringRepository _repository;

  MonitoringCubit(this._repository) : super(const MonitoringState());

  Future<void> loadData({
    int? selectedPort,
    bool clearPort = false,
    String? query,
  }) async {
    final nextPort = clearPort ? null : (selectedPort ?? state.selectedPort);
    final nextQuery = query ?? state.searchQuery;

    emit(state.copyWith(
      selectedPort: nextPort,
      clearSelectedPort: clearPort,
      searchQuery: nextQuery,
      isLoading: true,
    ));

    final items = await _repository.getMonitoredObjects(
      allowedPorts: state.allowedPorts,
      selectedPort: nextPort,
      query: nextQuery,
    );

    emit(state.copyWith(items: items, isLoading: false));
  }
}

