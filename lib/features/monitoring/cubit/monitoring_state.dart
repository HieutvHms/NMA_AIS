import 'package:equatable/equatable.dart';
import '../data/models/vessel_model.dart';

class MonitoringState extends Equatable {
  final List<VesselModel> items;
  final List<int> allowedPorts;
  final int? selectedPort;
  final String searchQuery;
  final bool isLoading;

  const MonitoringState({
    this.items = const [],
    this.allowedPorts = const [5001, 5002],
    this.selectedPort,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<VesselModel> get vessels => items.where((e) => !e.isBuoy).toList();
  List<VesselModel> get buoys => items.where((e) => e.isBuoy).toList();

  MonitoringState copyWith({
    List<VesselModel>? items,
    List<int>? allowedPorts,
    int? selectedPort,
    bool clearSelectedPort = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MonitoringState(
      items: items ?? this.items,
      allowedPorts: allowedPorts ?? this.allowedPorts,
      selectedPort:
          clearSelectedPort ? null : (selectedPort ?? this.selectedPort),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        items,
        allowedPorts,
        selectedPort,
        searchQuery,
        isLoading,
      ];
}

