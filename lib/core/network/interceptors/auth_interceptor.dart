import 'dart:async';
import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';
import '../../constants/app_constants.dart';
import '../../storage/local_storage.dart';
import '../token_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;
  final TokenRefreshCoordinator _refreshCoordinator;
  final Dio _retryDio;

  AuthInterceptor(this._localStorage, this._refreshCoordinator)
    : _retryDio = Dio(
        BaseOptions(
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );

  bool _isAuthEndpoint(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.refreshToken) ||
        path.contains(ApiEndpoints.logout);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Không đính kèm Bearer token cho login, refresh và logout
    if (!_isAuthEndpoint(options.path)) {
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
    final isAuthPath = _isAuthEndpoint(err.requestOptions.path);

    // Chỉ can thiệp khi gặp 401 Unauthorized và không phải request auth
    if (response?.statusCode == 401 && !isAuthPath) {
      // Nếu token đã được một request khác làm mới trong lúc request này đang bay,
      // chỉ cần retry ngay bằng token mới mà không gọi lại /auth/refresh.
      final requestAuthHeader = err.requestOptions.headers['Authorization']
          ?.toString();
      final currentToken = _localStorage.getToken();
      if (currentToken != null &&
          currentToken.isNotEmpty &&
          requestAuthHeader != 'Bearer $currentToken') {
        return _retryRequest(err.requestOptions, currentToken, handler);
      }

      final result = await _refreshCoordinator.refresh();

      if (result.isSuccess && result.accessToken != null) {
        return _retryRequest(err.requestOptions, result.accessToken!, handler);
      }

      if (result.isInvalidSession) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: result.dioException?.response ?? err.response,
            error:
                result.message ??
                'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.',
            type: DioExceptionType.badResponse,
          ),
        );
      }

      // Lỗi mạng / 5xx khi refresh: KHÔNG xóa phiên, trả về lỗi mạng để UI xử lý
      return handler.reject(result.dioException ?? err);
    }

    handler.next(err);
  }

  Future<void> _retryRequest(
    RequestOptions options,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    try {
      final retryResponse = await _retryDio.fetch(options);
      handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      handler.reject(retryErr);
    }
  }
}
