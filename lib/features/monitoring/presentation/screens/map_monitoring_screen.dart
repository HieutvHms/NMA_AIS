import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/entities/map_bounds_entity.dart';
import '../cubit/map_monitoring_cubit.dart';
import '../cubit/map_monitoring_state.dart';
import '../utils/ais_detail_overlay_controller.dart';
import '../utils/ais_marker_icon_cache.dart';
import '../utils/ais_marker_manager.dart';
import '../widgets/ais_target_list_sheet.dart';
import '../widgets/map_status_banner.dart';
import '../widgets/map_top_overlay_bar.dart';

/// Màn hình Giám sát thiết bị & tàu thuyền AIS trên bản đồ Google Maps.
class MapMonitoringScreen extends StatefulWidget {
  const MapMonitoringScreen({super.key});

  @override
  State<MapMonitoringScreen> createState() => _MapMonitoringScreenState();
}

class _MapMonitoringScreenState extends State<MapMonitoringScreen>
    with WidgetsBindingObserver {
  static const _clusterManagerId = ClusterManagerId('ais_targets_cluster');

  static const _initialVietnamCamera = CameraPosition(
    target: LatLng(
      AppConstants.vietnamCenterLat,
      AppConstants.vietnamCenterLng,
    ),
    zoom: AppConstants.vietnamDefaultZoom,
  );

  GoogleMapController? _mapController;
  late final Set<ClusterManager> _clusterManagers;
  final _markerManager = AisMarkerManager();
  final _detailOverlay = AisDetailOverlayController();

  double _currentZoom = AppConstants.vietnamDefaultZoom;
  bool _isClusteringEnabled = AppConstants.enableMapClustering;
  bool _iconsReady = false;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _clusterManagers = AppConstants.enableMapClustering
        ? {
            ClusterManager(
              clusterManagerId: _clusterManagerId,
              onClusterTap: _handleClusterTap,
            ),
          }
        : const {};

    AisMarkerIconCache.ensureInitialized().then((_) {
      if (!mounted) return;
      setState(() {
        _iconsReady = true;
        _rebuildAllMarkers(context.read<MapMonitoringCubit>().state);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScreenActiveWithRoute();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    _isAppInForeground = lifecycleState == AppLifecycleState.resumed;
    if (!mounted) return;
    _syncScreenActiveWithRoute();
  }

  /// Tạm dừng timer 10s khi rời tab Giám sát hoặc app vào background.
  void _syncScreenActiveWithRoute() {
    final currentPath = GoRouterState.of(context).uri.path;
    final isMonitoringTabVisible = currentPath == RouteNames.monitoring;
    if (!isMonitoringTabVisible) {
      _detailOverlay.hide();
    }
    context.read<MapMonitoringCubit>().setScreenActive(
      isMonitoringTabVisible && _isAppInForeground,
    );
  }

  @override
  void dispose() {
    _detailOverlay.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _notifyViewportBounds();
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    if (!AppConstants.enableMapClustering) return;

    final shouldCluster = _currentZoom < AppConstants.mapClusterDisableZoom;
    if (shouldCluster != _isClusteringEnabled) {
      setState(() {
        _isClusteringEnabled = shouldCluster;
        _rebuildAllMarkers(context.read<MapMonitoringCubit>().state);
      });
    }
  }

  Future<void> _notifyViewportBounds() async {
    final controller = _mapController;
    if (controller == null || !mounted) return;

    if (_markerManager.updateGridStepIfChanged(_currentZoom)) {
      _syncMarkersIncrementally(context.read<MapMonitoringCubit>().state);
    }

    try {
      final region = await controller.getVisibleRegion();
      if (!mounted) return;

      context.read<MapMonitoringCubit>().onViewportChanged(
        MapBoundsEntity(
          minLat: math.min(
            region.southwest.latitude,
            region.northeast.latitude,
          ),
          minLng: region.southwest.longitude,
          maxLat: math.max(
            region.southwest.latitude,
            region.northeast.latitude,
          ),
          maxLng: region.northeast.longitude,
        ),
      );
    } catch (_) {
      // Bỏ qua nếu bản đồ chưa layout xong ở frame đầu tiên
    }
  }

  Future<void> _handleClusterTap(Cluster cluster) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(cluster.bounds, 56.r),
    );
  }

  Future<void> _moveCameraToTarget(AisTargetEntity target) async {
    if (target.latitude == 0.0 && target.longitude == 0.0) return;
    final targetZoom = math.max(_currentZoom, AppConstants.mapTargetFocusZoom);
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(target.latitude, target.longitude),
        targetZoom,
      ),
    );
  }

  void _syncMarkersIncrementally(MapMonitoringState state) {
    if (!_iconsReady) return;
    final changed = _markerManager.syncIncrementally(
      state,
      zoom: _currentZoom,
      isClusteringEnabled: _isClusteringEnabled,
      clusterManagerId: _clusterManagerId,
      onMarkerTap: (target) =>
          context.read<MapMonitoringCubit>().selectTargetFromMarker(target),
    );
    if (changed) setState(() {});
  }

  void _rebuildAllMarkers(MapMonitoringState state) {
    if (!_iconsReady) return;
    _markerManager.rebuildAll(
      state,
      zoom: _currentZoom,
      isClusteringEnabled: _isClusteringEnabled,
      clusterManagerId: _clusterManagerId,
      onMarkerTap: (target) =>
          context.read<MapMonitoringCubit>().selectTargetFromMarker(target),
    );
  }

  void _openTargetListSheet() {
    final cubit = context.read<MapMonitoringCubit>();
    _detailOverlay.hide();
    cubit.clearSelectedTarget();
    cubit.loadAllTargets();
    AisTargetListSheet.show(
      context,
      cubit: cubit,
      onTargetTap: cubit.focusAndInspectTarget,
      onSearchGlobalMmsi: cubit.searchByMmsi,
    );
  }

  void _showSearchFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          content: Text(
            message,
            style: AppTextStyles.s13w500(color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapMonitoringCubit, MapMonitoringState>(
          listenWhen: (prev, curr) =>
              prev.targets != curr.targets ||
              prev.selectedTarget != curr.selectedTarget,
          listener: (_, state) => _syncMarkersIncrementally(state),
        ),
        BlocListener<MapMonitoringCubit, MapMonitoringState>(
          listenWhen: (prev, curr) =>
              prev.selectedTarget != curr.selectedTarget,
          listener: (context, state) {
            _detailOverlay.sync(
              context,
              target: state.selectedTarget,
              onCenterCamera: _moveCameraToTarget,
              onClose: () {
                if (mounted) {
                  context.read<MapMonitoringCubit>().clearSelectedTarget();
                } else {
                  _detailOverlay.hide();
                }
              },
            );
          },
        ),
        BlocListener<MapMonitoringCubit, MapMonitoringState>(
          listenWhen: (prev, curr) =>
              prev.cameraMoveRequestId != curr.cameraMoveRequestId &&
              curr.cameraFocusTarget != null,
          listener: (_, state) => _moveCameraToTarget(state.cameraFocusTarget!),
        ),
        BlocListener<MapMonitoringCubit, MapMonitoringState>(
          listenWhen: (prev, curr) =>
              prev.searchFeedbackMessage != curr.searchFeedbackMessage &&
              curr.searchFeedbackMessage != null,
          listener: (context, state) {
            _showSearchFeedback(state.searchFeedbackMessage!);
            context.read<MapMonitoringCubit>().clearSearchFeedback();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. Bản đồ Google Maps toàn màn hình
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialVietnamCamera,
                mapType: MapType.normal,
                markers: _markerManager.markers,
                clusterManagers: _clusterManagers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                onMapCreated: _onMapCreated,
                onCameraMove: _onCameraMove,
                onCameraIdle: _notifyViewportBounds,
                onTap: (_) =>
                    context.read<MapMonitoringCubit>().clearSelectedTarget(),
              ),
            ),

            // 2. Thanh trên cùng: nút Danh sách
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlocBuilder<MapMonitoringCubit, MapMonitoringState>(
                buildWhen: (prev, curr) =>
                    prev.totalInView != curr.totalInView ||
                    prev.isRefreshing != curr.isRefreshing,
                builder: (_, state) => MapTopOverlayBar(
                  totalInView: state.totalInView,
                  isRefreshing: state.isRefreshing,
                  onOpenListTap: _openTargetListSheet,
                ),
              ),
            ),

            // 3. Nút quay về toàn cảnh vùng biển Việt Nam
            Positioned(
              right: 12.w,
              bottom: 20.h,
              child: FloatingActionButton.small(
                heroTag: 'reset_vietnam_sea_btn',
                tooltip: 'Về vùng biển Việt Nam',
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                elevation: 3,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(_initialVietnamCamera),
                  );
                },
                child: Icon(Icons.public_rounded, size: 20.r),
              ),
            ),

            // 4. Banner trạng thái Loading / Empty / Error + Nút Thử lại
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.h,
              child: Center(
                child: BlocBuilder<MapMonitoringCubit, MapMonitoringState>(
                  buildWhen: (prev, curr) =>
                      prev.isInitialLoading != curr.isInitialLoading ||
                      prev.isEmptyInView != curr.isEmptyInView ||
                      prev.errorMessage != curr.errorMessage ||
                      prev.isNetworkError != curr.isNetworkError,
                  builder: (context, state) => MapStatusBanner(
                    isInitialLoading: state.isInitialLoading,
                    isEmptyInView: state.isEmptyInView,
                    errorMessage: state.errorMessage,
                    isNetworkError: state.isNetworkError,
                    onRetry: () => context.read<MapMonitoringCubit>().retry(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
