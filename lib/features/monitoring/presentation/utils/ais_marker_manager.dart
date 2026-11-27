import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../cubit/map_monitoring_state.dart';
import 'ais_marker_icon_cache.dart';

/// Quản lý tập Marker trên GoogleMap: lọc trùng tọa độ theo mức zoom và diff O(n)
/// để chỉ cập nhật những marker thực sự thay đổi, tránh giật/nháy bản đồ.
class AisMarkerManager {
  final Map<String, Marker> _markersByMmsi = {};
  final Map<String, AisTargetEntity> _renderedTargetsByMmsi = {};

  Set<Marker> _markerSet = const {};
  String? _lastSelectedMmsi;
  double _lastGridStep = 0.25;

  Set<Marker> get markers => _markerSet;

  /// Kiểm tra xem mức zoom mới có chuyển sang ngưỡng bước lưới khác hay không.
  bool updateGridStepIfChanged(double zoom) {
    final nextStep = _gridStepForZoom(zoom);
    if (nextStep == _lastGridStep) return false;
    _lastGridStep = nextStep;
    return true;
  }

  /// Đồng bộ tăng dần: chỉ thêm/sửa/xoá các marker có thay đổi.
  /// Trả về `true` nếu tập marker thay đổi và UI cần `setState`.
  bool syncIncrementally(
    MapMonitoringState state, {
    required double zoom,
    required bool isClusteringEnabled,
    required ClusterManagerId clusterManagerId,
    required ValueChanged<AisTargetEntity> onMarkerTap,
  }) {
    final nextTargetsMap = _selectVisibleTargets(state, zoom);
    final nextSelectedMmsi = state.selectedTarget?.mmsi;
    var hasMutation = false;

    final removedKeys = _markersByMmsi.keys
        .where((mmsi) => !nextTargetsMap.containsKey(mmsi))
        .toList(growable: false);
    for (final mmsi in removedKeys) {
      _markersByMmsi.remove(mmsi);
      _renderedTargetsByMmsi.remove(mmsi);
      hasMutation = true;
    }

    for (final entry in nextTargetsMap.entries) {
      final mmsi = entry.key;
      final target = entry.value;
      final prevTarget = _renderedTargetsByMmsi[mmsi];
      final selectionChanged =
          (mmsi == _lastSelectedMmsi) != (mmsi == nextSelectedMmsi);

      if (prevTarget == null ||
          _hasVisualChanged(prevTarget, target) ||
          selectionChanged) {
        _markersByMmsi[mmsi] = _buildMarker(
          target,
          isSelected: mmsi == nextSelectedMmsi,
          isClusteringEnabled: isClusteringEnabled,
          clusterManagerId: clusterManagerId,
          onTap: () => onMarkerTap(target),
        );
        _renderedTargetsByMmsi[mmsi] = target;
        hasMutation = true;
      }
    }

    _lastSelectedMmsi = nextSelectedMmsi;
    if (hasMutation) {
      _markerSet = Set<Marker>.of(_markersByMmsi.values);
    }
    return hasMutation;
  }

  /// Dựng lại toàn bộ marker (dùng khi icon vừa tải xong hoặc đổi chế độ clustering).
  void rebuildAll(
    MapMonitoringState state, {
    required double zoom,
    required bool isClusteringEnabled,
    required ClusterManagerId clusterManagerId,
    required ValueChanged<AisTargetEntity> onMarkerTap,
  }) {
    _markersByMmsi.clear();
    _renderedTargetsByMmsi.clear();

    final visibleTargets = _selectVisibleTargets(state, zoom);
    final selectedMmsi = state.selectedTarget?.mmsi;
    for (final target in visibleTargets.values) {
      _markersByMmsi[target.mmsi] = _buildMarker(
        target,
        isSelected: target.mmsi == selectedMmsi,
        isClusteringEnabled: isClusteringEnabled,
        clusterManagerId: clusterManagerId,
        onTap: () => onMarkerTap(target),
      );
      _renderedTargetsByMmsi[target.mmsi] = target;
    }
    _lastSelectedMmsi = selectedMmsi;
    _markerSet = Set<Marker>.of(_markersByMmsi.values);
  }

  /// Bước lưới tọa độ theo mức zoom để bỏ bớt tàu đè khít pixel ở zoom xa.
  double _gridStepForZoom(double zoom) {
    if (zoom >= 10.5) return 0.0; // Zoom gần: hiện 100% tàu trong vùng nhìn
    if (zoom >= 8.5) return 0.06;
    if (zoom >= 7.0) return 0.14;
    return 0.25; // Zoom toàn cảnh Việt Nam (~5.8)
  }

  Map<String, AisTargetEntity> _selectVisibleTargets(
    MapMonitoringState state,
    double zoom,
  ) {
    final step = _gridStepForZoom(zoom);
    final selectedMmsi = state.selectedTarget?.mmsi;
    final visible = <String, AisTargetEntity>{};
    final occupiedVesselCells = <int>{};

    for (final target in state.targets) {
      // // Bỏ qua các bản ghi lỗi tọa độ (0, 0) khỏi bản đồ
      // if (target.latitude == 0.0 && target.longitude == 0.0) continue;
      // Zoom gần hoặc Trạm/Đèn biển hoặc đối tượng đang chọn -> luôn giữ 100%
      if (step <= 0.0 ||
          target.isStationOrAton ||
          target.mmsi == selectedMmsi) {
        visible[target.mmsi] = target;
        continue;
      }

      final cellLat = (target.latitude / step).floor();
      final cellLng = (target.longitude / step).floor();
      final cellKey = (cellLat * 100000) ^ cellLng;
      if (occupiedVesselCells.add(cellKey)) {
        visible[target.mmsi] = target;
      }
    }

    return visible;
  }

  /// Chỉ tạo lại Marker khi vị trí hoặc loại đối tượng đổi (bỏ qua `updatedAt`).
  bool _hasVisualChanged(AisTargetEntity prev, AisTargetEntity next) {
    return prev.type != next.type ||
        prev.latitude != next.latitude ||
        prev.longitude != next.longitude;
  }

  Marker _buildMarker(
    AisTargetEntity target, {
    required bool isSelected,
    required bool isClusteringEnabled,
    required ClusterManagerId clusterManagerId,
    required VoidCallback onTap,
  }) {
    final isStation = target.isStationOrAton;

    final shouldClusterMarker =
        AppConstants.enableMapClustering &&
        isClusteringEnabled &&
        !isStation &&
        !isSelected;

    final markerIdValue = shouldClusterMarker
        ? '${target.mmsi}_${target.latitude.toStringAsFixed(6)}_${target.longitude.toStringAsFixed(6)}_1'
        : target.mmsi;

    return Marker(
      markerId: MarkerId(markerIdValue),
      position: LatLng(target.latitude, target.longitude),
      icon: AisMarkerIconCache.iconFor(
        type: target.type,
        isSelected: isSelected,
      ),
      anchor: const Offset(0.5, 0.5),
      flat: false,
      rotation: 0.0,
      zIndexInt: isSelected ? 10 : (isStation ? 5 : 1),
      clusterManagerId: shouldClusterMarker ? clusterManagerId : null,
      consumeTapEvents: true,
      onTap: onTap,
    );
  }
}
