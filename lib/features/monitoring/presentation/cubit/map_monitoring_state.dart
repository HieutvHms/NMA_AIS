import 'package:equatable/equatable.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/entities/map_bounds_entity.dart';

class MapMonitoringState extends Equatable {
  final List<AisTargetEntity> targets;
  final Map<String, AisTargetEntity> targetsByMmsi;
  final List<AisTargetEntity> allTargets;
  final bool isLoadingAllTargets;
  final String? allTargetsError;
  final MapBoundsEntity? currentBounds;
  final bool isInitialLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final bool isNetworkError;
  final AisTargetEntity? selectedTarget;
  final AisTargetEntity? cameraFocusTarget;
  final int cameraMoveRequestId;
  final String? searchFeedbackMessage;

  const MapMonitoringState({
    this.targets = const [],
    this.targetsByMmsi = const {},
    this.allTargets = const [],
    this.isLoadingAllTargets = false,
    this.allTargetsError,
    this.currentBounds,
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.errorMessage,
    this.isNetworkError = false,
    this.selectedTarget,
    this.cameraFocusTarget,
    this.cameraMoveRequestId = 0,
    this.searchFeedbackMessage,
  });

  int get totalInView => targets.length;
  bool get isEmptyInView =>
      !isInitialLoading && errorMessage == null && targets.isEmpty;

  MapMonitoringState copyWith({
    List<AisTargetEntity>? targets,
    Map<String, AisTargetEntity>? targetsByMmsi,
    List<AisTargetEntity>? allTargets,
    bool? isLoadingAllTargets,
    String? allTargetsError,
    bool clearAllTargetsError = false,
    MapBoundsEntity? currentBounds,
    bool? isInitialLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    bool? isNetworkError,
    AisTargetEntity? selectedTarget,
    bool clearSelectedTarget = false,
    AisTargetEntity? cameraFocusTarget,
    int? cameraMoveRequestId,
    String? searchFeedbackMessage,
    bool clearSearchFeedback = false,
  }) {
    return MapMonitoringState(
      targets: targets ?? this.targets,
      targetsByMmsi: targetsByMmsi ?? this.targetsByMmsi,
      allTargets: allTargets ?? this.allTargets,
      isLoadingAllTargets: isLoadingAllTargets ?? this.isLoadingAllTargets,
      allTargetsError: clearAllTargetsError
          ? null
          : (allTargetsError ?? this.allTargetsError),
      currentBounds: currentBounds ?? this.currentBounds,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNetworkError: clearError
          ? false
          : (isNetworkError ?? this.isNetworkError),
      selectedTarget: clearSelectedTarget
          ? null
          : (selectedTarget ?? this.selectedTarget),
      cameraFocusTarget: cameraFocusTarget ?? this.cameraFocusTarget,
      cameraMoveRequestId: cameraMoveRequestId ?? this.cameraMoveRequestId,
      searchFeedbackMessage: clearSearchFeedback
          ? null
          : (searchFeedbackMessage ?? this.searchFeedbackMessage),
    );
  }

  @override
  List<Object?> get props => [
    targets,
    allTargets,
    isLoadingAllTargets,
    allTargetsError,
    currentBounds,
    isInitialLoading,
    isRefreshing,
    errorMessage,
    isNetworkError,
    selectedTarget,
    cameraFocusTarget,
    cameraMoveRequestId,
    searchFeedbackMessage,
  ];
}
