import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';
import 'interceptors/auth_interceptor.dart';

class DioClient {
  late final Dio dio;
  final LocalStorage _localStorage;
  final VoidCallback? onSessionExpired;

  DioClient(this._localStorage, {this.onSessionExpired}) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.managerBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(_localStorage, onSessionExpired: onSessionExpired),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          // Chỉ in log trong chế độ development
          if (AppConfig.isDevelopment) {
            // ignore: avoid_print
            print('[DIO] $obj');
          }
        },
      ),
    ]);
  }
}
