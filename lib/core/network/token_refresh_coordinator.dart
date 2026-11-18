import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

enum TokenRefreshStatus { success, invalidSession, networkError }

class TokenRefreshResult {
  final TokenRefreshStatus status;
  final String? accessToken;
  final String? refreshToken;
  final String? message;
  final DioException? dioException;

  const TokenRefreshResult._({
    required this.status,
    this.accessToken,
    this.refreshToken,
    this.message,
    this.dioException,
  });

  factory TokenRefreshResult.success({
    required String accessToken,
    required String refreshToken,
  }) => TokenRefreshResult._(
    status: TokenRefreshStatus.success,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  factory TokenRefreshResult.invalidSession({
    String? message,
    DioException? dioException,
  }) => TokenRefreshResult._(
    status: TokenRefreshStatus.invalidSession,
    message: message ?? 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.',
    dioException: dioException,
  );

  factory TokenRefreshResult.networkError({
    String? message,
    DioException? dioException,
  }) => TokenRefreshResult._(
    status: TokenRefreshStatus.networkError,
    message: message ?? 'Không thể kết nối máy chủ để làm mới phiên.',
    dioException: dioException,
  );

  bool get isSuccess => status == TokenRefreshStatus.success;
  bool get isInvalidSession => status == TokenRefreshStatus.invalidSession;
  bool get isNetworkError => status == TokenRefreshStatus.networkError;
}

/// Điều phối làm mới token theo cơ chế single-flight:
/// - Chỉ gửi tối đa 1 request POST /auth/refresh tại một thời điểm.
/// - Các request 401 đồng thời hoặc logout sẽ chờ cùng một Future.
/// - Phân biệt rõ INVALID_REFRESH_TOKEN (401 -> xóa phiên) và lỗi mạng (giữ phiên).
class TokenRefreshCoordinator {
  final LocalStorage _localStorage;
  final VoidCallback? onSessionExpired;
  final Dio _refreshDio;

  Future<TokenRefreshResult>? _inFlightRefresh;

  TokenRefreshCoordinator(this._localStorage, {this.onSessionExpired})
    : _refreshDio = Dio(
        BaseOptions(
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );

  bool get isRefreshing => _inFlightRefresh != null;

  /// Chờ request refresh đang chạy (nếu có) hoàn tất trước khi thực hiện thao tác khác (như logout).
  Future<void> waitForPendingRefresh() async {
    final pending = _inFlightRefresh;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {}
    }
  }

  /// Thực hiện làm mới token hoặc dùng lại kết quả của request đang chạy.
  Future<TokenRefreshResult> refresh() {
    final existing = _inFlightRefresh;
    if (existing != null) {
      return existing;
    }

    final future = _performRefresh();
    _inFlightRefresh = future;
    future.whenComplete(() {
      if (identical(_inFlightRefresh, future)) {
        _inFlightRefresh = null;
      }
    });
    return future;
  }

  Future<TokenRefreshResult> _performRefresh() async {
    final currentRefreshToken = _localStorage.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await _localStorage.clearSession();
      onSessionExpired?.call();
      return TokenRefreshResult.invalidSession();
    }

    try {
      final response = await _refreshDio.post(
        AppConfig.refreshTokenUrl,
        data: {'refreshToken': currentRefreshToken},
      );

      final resData = response.data;
      if (resData is! Map<String, dynamic>) {
        return TokenRefreshResult.networkError(
          message: 'Dữ liệu làm mới token không hợp lệ.',
        );
      }

      final success = resData['success'] == true;
      final code = resData['code']?.toString() ?? '';
      final message = resData['message']?.toString();

      if (!success) {
        if (code == 'INVALID_REFRESH_TOKEN') {
          await _localStorage.clearSession();
          onSessionExpired?.call();
          return TokenRefreshResult.invalidSession(message: message);
        }
        return TokenRefreshResult.networkError(message: message);
      }

      final data = resData['data'];
      if (data is! Map<String, dynamic>) {
        return TokenRefreshResult.networkError(
          message: 'Không nhận được dữ liệu token mới.',
        );
      }

      final newAccessToken = data['accessToken']?.toString() ?? '';
      final newRefreshToken = data['refreshToken']?.toString() ?? '';

      if (newAccessToken.isEmpty) {
        return TokenRefreshResult.networkError(
          message: 'Access token mới rỗng.',
        );
      }

      await _localStorage.saveToken(newAccessToken);
      if (newRefreshToken.isNotEmpty) {
        await _localStorage.saveRefreshToken(newRefreshToken);
      }
      if (data['userId'] != null) {
        await _localStorage.saveUserId(data['userId'].toString());
      }
      if (data['role'] != null) {
        await _localStorage.saveRole(data['role'].toString());
      }

      return TokenRefreshResult.success(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken.isNotEmpty
            ? newRefreshToken
            : currentRefreshToken,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final resData = e.response?.data;
      final errorCode = resData is Map ? resData['code']?.toString() : null;
      final serverMessage = resData is Map
          ? resData['message']?.toString()
          : null;

      // BE trả HTTP 401 / INVALID_REFRESH_TOKEN -> phiên không hợp lệ hoặc đã hết hạn
      if (statusCode == 401 || errorCode == 'INVALID_REFRESH_TOKEN') {
        await _localStorage.clearSession();
        onSessionExpired?.call();
        return TokenRefreshResult.invalidSession(
          message: serverMessage,
          dioException: e,
        );
      }

      // Lỗi mạng, timeout hoặc lỗi 5xx từ server -> KHÔNG xóa phiên
      return TokenRefreshResult.networkError(
        message: serverMessage,
        dioException: e,
      );
    } catch (_) {
      return TokenRefreshResult.networkError();
    }
  }
}

