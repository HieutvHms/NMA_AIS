import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/usecases/get_all_map_targets_usecase.dart';
import '../../domain/usecases/search_map_target_by_mmsi_usecase.dart';
import 'map_monitoring_state.dart';

class MapMonitoringCubit extends Cubit<MapMonitoringState> {
  final GetAllMapTargetsUseCase _getAllMapTargetsUseCase;
  final SearchMapTargetByMmsiUseCase _searchMapTargetByMmsiUseCase;

  Timer? _autoRefreshTimer;
  CancelToken? _mapCancelToken;
  CancelToken? _allTargetsCancelToken;
  CancelToken? _searchCancelToken;
  bool _isScreenActive = true;

  MapMonitoringCubit({
    required GetAllMapTargetsUseCase getAllMapTargetsUseCase,
    required SearchMapTargetByMmsiUseCase searchMapTargetByMmsiUseCase,
  }) : _getAllMapTargetsUseCase = getAllMapTargetsUseCase,
       _searchMapTargetByMmsiUseCase = searchMapTargetByMmsiUseCase,
       super(const MapMonitoringState()) {
    _startAutoRefreshTimer();
    _fetchTargets(isAutoRefresh: false);
  }

  // Thử tải lại dữ liệu khi gặp lỗi mạng / máy chủ.
  Future<void> retry() async {
    await _fetchTargets(isAutoRefresh: false, forceRefresh: true);
  }

  /// Điều khiển tạm dừng / tiếp tục timer 10s khi chuyển tab hoặc app vào background.
  void setScreenActive(bool active) {
    if (_isScreenActive == active) return;
    _isScreenActive = active;

    if (!active) {
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      _mapCancelToken?.cancel('Screen inactive');
      _searchCancelToken?.cancel('Screen inactive');
      if (state.isRefreshing) {
        emit(state.copyWith(isRefreshing: false));
      }
    } else {
      _startAutoRefreshTimer();
      _fetchTargets(isAutoRefresh: true);
    }
  }

  // Chọn đối tượng khi người dùng chạm trực tiếp vào marker trên bản đồ.
  void selectTargetFromMarker(AisTargetEntity target) {
    emit(state.copyWith(selectedTarget: target));
  }

  // Tải toàn bộ danh sách trạm và tàu mà user được phép xem (cho bottom sheet Danh sách).
  Future<void> loadAllTargets({bool forceRefresh = false}) async {
    if (state.isLoadingAllTargets && !forceRefresh) return;

    _allTargetsCancelToken?.cancel('Superseded by newer all-targets request');
    final token = CancelToken();
    _allTargetsCancelToken = token;

    emit(
      state.copyWith(isLoadingAllTargets: true, clearAllTargetsError: true),
    );

    try {
      final all = await _getAllMapTargetsUseCase(
        cancelToken: token,
        forceRefresh: forceRefresh,
      );
      if (isClosed || token.isCancelled) return;
      emit(
        state.copyWith(
          allTargets: all,
          isLoadingAllTargets: false,
          clearAllTargetsError: true,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || isClosed) return;
      emit(
        state.copyWith(
          isLoadingAllTargets: false,
          allTargetsError: ErrorMapper.map(e).message,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingAllTargets: false,
          allTargetsError: failure.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingAllTargets: false,
          allTargetsError: ErrorMapper.map(e).message,
        ),
      );
    }
  }

  // Chọn đối tượng từ bảng Danh sách: đảm bảo có marker, bay camera tới và mở thông tin.
  void focusAndInspectTarget(AisTargetEntity target) {
    if (!state.targetsByMmsi.containsKey(target.mmsi)) {
      final updatedMap = Map<String, AisTargetEntity>.from(state.targetsByMmsi);
      updatedMap[target.mmsi] = target;
      emit(
        state.copyWith(
          targets: updatedMap.values.toList(growable: false),
          targetsByMmsi: updatedMap,
          selectedTarget: target,
          cameraFocusTarget: target,
          cameraMoveRequestId: state.cameraMoveRequestId + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedTarget: target,
        cameraFocusTarget: target,
        cameraMoveRequestId: state.cameraMoveRequestId + 1,
      ),
    );
  }

  void clearSelectedTarget() {
    if (state.selectedTarget != null) {
      emit(state.copyWith(clearSelectedTarget: true));
    }
  }

  void clearSearchFeedback() {
    if (state.searchFeedbackMessage != null) {
      emit(state.copyWith(clearSearchFeedback: true));
    }
  }

  // Tìm kiếm đối tượng theo MMSI: ưu tiên vùng nhìn hiện tại, sau đó hỏi DataSource.
  Future<void> searchByMmsi(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    // 1. Kiểm tra nhanh trong tập đối tượng đang hiển thị
    final exactLocal = state.targetsByMmsi[query];
    if (exactLocal != null) {
      focusAndInspectTarget(exactLocal);
      return;
    }

    _searchCancelToken?.cancel('New MMSI search');
    final token = CancelToken();
    _searchCancelToken = token;

    emit(state.copyWith(clearSearchFeedback: true));

    try {
      final found = await _searchMapTargetByMmsiUseCase(
        query,
        cancelToken: token,
      );
      if (isClosed) return;

      if (found == null) {
        emit(
          state.copyWith(
            searchFeedbackMessage:
                'Không tìm thấy đối tượng AIS có MMSI "$query".',
          ),
        );
        return;
      }

      // Đảm bảo đối tượng tìm thấy luôn có mặt ngay trong danh sách hiện tại trước khi camera bay tới
      final updatedMap = Map<String, AisTargetEntity>.from(state.targetsByMmsi);
      updatedMap[found.mmsi] = found;

      emit(
        state.copyWith(
          targets: updatedMap.values.toList(growable: false),
          targetsByMmsi: updatedMap,
          selectedTarget: found,
          cameraFocusTarget: found,
          cameraMoveRequestId: state.cameraMoveRequestId + 1,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || isClosed) return;
      emit(state.copyWith(searchFeedbackMessage: ErrorMapper.map(e).message));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(state.copyWith(searchFeedbackMessage: failure.message));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(searchFeedbackMessage: ErrorMapper.map(e).message));
    }
  }

  Future<void> _fetchTargets({
    required bool isAutoRefresh,
    bool forceRefresh = false,
  }) async {
    if (!_isScreenActive || isClosed) return;

    // Hủy ngay request trước đó để tránh race condition
    _mapCancelToken?.cancel('Superseded by newer map request');
    final token = CancelToken();
    _mapCancelToken = token;

    final isFirstLoad = state.isInitialLoading && state.targets.isEmpty;
    emit(
      state.copyWith(
        isInitialLoading: isFirstLoad,
        isRefreshing: !isFirstLoad,
        clearError: !isAutoRefresh,
      ),
    );

    try {
      final fetched = await _getAllMapTargetsUseCase(
        cancelToken: token,
        forceRefresh: forceRefresh || isAutoRefresh,
      );
      if (isClosed || token.isCancelled) return;

      // Giữ lại đối tượng đang được chọn (nếu có) để tránh mất marker đang xem chi tiết
      final nextMap = <String, AisTargetEntity>{
        for (final item in fetched) item.mmsi: item,
      };
      final currentSelected = state.selectedTarget;
      AisTargetEntity? updatedSelected = currentSelected;
      if (currentSelected != null &&
          nextMap.containsKey(currentSelected.mmsi)) {
        updatedSelected = nextMap[currentSelected.mmsi];
      }

      final hasChanged = _hasTargetsChanged(fetched);

      // Khi auto-refresh mà không có bất kỳ đối tượng nào thay đổi -> giữ nguyên list cũ
      if (isAutoRefresh && !hasChanged && state.errorMessage == null) {
        emit(state.copyWith(isInitialLoading: false, isRefreshing: false));
        return;
      }

      emit(
        state.copyWith(
          targets: fetched,
          targetsByMmsi: nextMap,
          selectedTarget: updatedSelected,
          isInitialLoading: false,
          isRefreshing: false,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      // Bỏ qua hoàn toàn nếu request chủ động bị hủy bởi CancelToken
      if (e.type == DioExceptionType.cancel || isClosed) return;
      _handleFailure(ErrorMapper.map(e));
    } on Failure catch (failure) {
      if (isClosed) return;
      _handleFailure(failure);
    } catch (e) {
      if (isClosed) return;
      _handleFailure(ErrorMapper.map(e));
    }
  }

  void _handleFailure(Failure failure) {
    emit(
      state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        errorMessage: failure.message,
        isNetworkError: failure is NetworkFailure,
      ),
    );
  }

  /// Kiểm tra nhanh O(n) xem danh sách đối tượng mới có thay đổi so với hiện tại hay không.
  bool _hasTargetsChanged(List<AisTargetEntity> nextList) {
    if (nextList.length != state.targetsByMmsi.length) return true;
    for (final item in nextList) {
      final prev = state.targetsByMmsi[item.mmsi];
      if (prev == null || prev != item) {
        return true;
      }
    }
    return false;
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(AppConstants.mapAutoRefreshInterval, (
      _,
    ) {
      if (_isScreenActive && !state.isInitialLoading && !state.isRefreshing) {
        _fetchTargets(isAutoRefresh: true);
      }
    });
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    _mapCancelToken?.cancel('Cubit closed');
    _allTargetsCancelToken?.cancel('Cubit closed');
    _searchCancelToken?.cancel('Cubit closed');
    return super.close();
  }
}
