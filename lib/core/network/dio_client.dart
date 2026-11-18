import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'token_refresh_coordinator.dart';

class DioClient {
  late final Dio dio;
  final LocalStorage _localStorage;
  final TokenRefreshCoordinator refreshCoordinator;
  final VoidCallback? onSessionExpired;

  DioClient(
    this._localStorage, {
    TokenRefreshCoordinator? refreshCoordinator,
    this.onSessionExpired,
  }) : refreshCoordinator =
           refreshCoordinator ??
           TokenRefreshCoordinator(
             _localStorage,
             onSessionExpired: onSessionExpired,
           ) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.managerBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(_localStorage, this.refreshCoordinator),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          // Chỉ in log trong chế độ development và tránh log chuỗi token nhạy cảm
          if (AppConfig.isDevelopment) {
            final text = obj.toString();
            final isSensitive =
                text.contains(ApiEndpoints.login) ||
                text.contains(ApiEndpoints.refreshToken) ||
                text.contains('accessToken') ||
                text.contains('refreshToken') ||
                text.contains('Authorization');
            if (!isSensitive) {
              // ignore: avoid_print
              print('[DIO] $obj');
            }
          }
        },
      ),
    ]);
  }
}
