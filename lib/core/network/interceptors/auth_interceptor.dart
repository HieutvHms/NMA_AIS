import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/local_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final LocalStorage _localStorage;
  final VoidCallback? onSessionExpired;
  final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _queue = [];

  AuthInterceptor(this._localStorage, {this.onSessionExpired})
    : _refreshDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Không đính kèm Bearer token cho endpoint login, register và refresh
    final isAuthEndpoint =
        options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refreshToken);

    if (!isAuthEndpoint) {
      final token = _localStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final isAuthPath =
        err.requestOptions.path.contains(ApiEndpoints.login) ||
        err.requestOptions.path.contains(ApiEndpoints.refreshToken);

    // Chỉ can thiệp khi gặp mã 401 Unauthorized và không phải request login/refresh
    if (response?.statusCode == 401 && !isAuthPath) {
      final oldAccessToken = _localStorage.getToken();
      final oldRefreshToken = _localStorage.getRefreshToken();

      // Nếu không có refreshToken thì không thể refresh -> đăng xuất
      if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
        await _localStorage.clearSession();
        return handler.next(err);
      }

      // Đưa request bị 401 vào hàng đợi
      _queue.add((options: err.requestOptions, handler: handler));

      // Nếu đang trong tiến trình refresh thì đợi kết quả
      if (_isRefreshing) return;

      _isRefreshing = true;

      try {
        // Gọi API refresh token
        final refreshResponse = await _refreshDio.post(
          AppConfig.refreshTokenUrl,
          data: {
            'accessToken': oldAccessToken ?? '',
            'refreshToken': oldRefreshToken,
          },
        );

        final resData = refreshResponse.data;
        final success =
            resData != null &&
            (resData['success'] == true || resData['data'] != null);

        if (success && resData['data'] != null) {
          final dataMap = resData['data'] as Map<String, dynamic>;
          final newAccessToken = dataMap['accessToken']?.toString() ?? '';
          final newRefreshToken = dataMap['refreshToken']?.toString() ?? '';

          if (newAccessToken.isNotEmpty) {
            await _localStorage.saveToken(newAccessToken);
            if (newRefreshToken.isNotEmpty) {
              await _localStorage.saveRefreshToken(newRefreshToken);
            }

            // Retry lại tất cả các request trong hàng đợi với token mới
            final queuedItems = List.of(_queue);
            _queue.clear();

            for (final item in queuedItems) {
              item.options.headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                final retryRes = await _refreshDio.fetch(item.options);
                item.handler.resolve(retryRes);
              } on DioException catch (retryErr) {
                item.handler.reject(retryErr);
              }
            }
            return;
          }
        }

        // Nếu refresh thất bại
        await _handleRefreshFailure();
      } catch (_) {
        await _handleRefreshFailure();
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.next(err);
  }

  Future<void> _handleRefreshFailure() async {
    await _localStorage.clearSession();
    onSessionExpired?.call();
    final queuedItems = List.of(_queue);
    _queue.clear();

    for (final item in queuedItems) {
      item.handler.reject(
        DioException(
          requestOptions: item.options,
          error: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }
}
