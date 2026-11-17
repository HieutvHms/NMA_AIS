import 'package:dio/dio.dart';
import 'package:ais/core/error/exceptions.dart';
import 'package:ais/core/error/failures.dart';

class ErrorMapper {
  ErrorMapper._();

  /// Chuyển bất kỳ Exception nào thành Failure phù hợp.
  static Failure map(Object e) {
    if (e is DioException) return _fromDio(e);
    if (e is ServerException) {
      if ((e.statusCode ?? 0) >= 500) {
        return const ServerFailure(
          message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau',
          code: 500,
        );
      }
      return ServerFailure(message: e.message, code: e.statusCode);
    }
    if (e is ValidationException) {
      final msg = e.errors.isNotEmpty
          ? e.errors.values.expand((element) => element).firstOrNull ??
                e.message
          : e.message;
      return ServerFailure(message: sanitize(msg), code: 422);
    }
    if (e is ForbiddenException) return const ForbiddenFailure();
    if (e is NotFoundException) return const NotFoundFailure();
    if (e is NetworkException) return _noInternet;
    if (e is CacheException) return CacheFailure(message: sanitize(e.message));
    if (e is String) {
      return ServerFailure(message: sanitize(e));
    }
    if (e is Exception) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return ServerFailure(message: sanitize(msg));
    }
    // Exception thông thường (ném từ DataSource khi parse thất bại, v.v.)
    return const ServerFailure(
      message: 'Không thể tải dữ liệu. Vui lòng thử lại.',
    );
  }

  /// Làm sạch thông báo lỗi, loại bỏ hoàn toàn các thông tin kỹ thuật (500, DioException, ServerException,...)
  static String sanitize(String? message) {
    if (message == null || message.trim().isEmpty) {
      return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau';
    }
    final lower = message.toLowerCase();
    if (lower.contains('500') ||
        lower.contains('dioexception') ||
        lower.contains('serverexception') ||
        lower.contains('bad response') ||
        lower.contains('internal server error') ||
        lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused')) {
      return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau';
    }
    return message;
  }

  static Failure _fromDio(DioException e) {
    // Nếu ErrorInterceptor đã bọc lỗi vào thuộc tính error
    if (e.error is NetworkException) return _noInternet;
    if (e.error is ServerException) {
      final ex = e.error as ServerException;
      if ((ex.statusCode ?? 0) >= 500) {
        return const ServerFailure(
          message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
          code: 500,
        );
      }
      return ServerFailure(message: ex.message, code: ex.statusCode);
    }
    if (e.error is ValidationException) {
      final ex = e.error as ValidationException;
      final msg = ex.errors.isNotEmpty
          ? ex.errors.values.expand((element) => element).firstOrNull ??
                ex.message
          : ex.message;
      return ServerFailure(message: sanitize(msg), code: 422);
    }
    if (e.error is ForbiddenException) return const ForbiddenFailure();
    if (e.error is NotFoundException) return const NotFoundFailure();

    switch (e.type) {
      case DioExceptionType.connectionError:
        return _noInternet;

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Kết nối quá chậm.\nVui lòng kiểm tra mạng và thử lại.',
        );

      case DioExceptionType.badResponse:
        return _fromHttpStatus(e);

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Yêu cầu đã bị huỷ.');

      default:
        return _noInternet;
    }
  }

  static Failure _fromHttpStatus(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    final serverMsg = data is Map ? data['message']?.toString() : null;

    return switch (code) {
      401 =>
        serverMsg != null && serverMsg.isNotEmpty
            ? ServerFailure(message: sanitize(serverMsg), code: code)
            : const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      404 => const NotFoundFailure(),
      422 => ServerFailure(
        message: serverMsg ?? 'Dữ liệu không hợp lệ.',
        code: code,
      ),
      _ when (code ?? 0) >= 500 => const ServerFailure(
        message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
      ),
      _ => ServerFailure(
        message: serverMsg ?? 'Đã xảy ra lỗi. Vui lòng thử lại.',
        code: code,
      ),
    };
  }

  static const NetworkFailure _noInternet = NetworkFailure(
    message:
        'Không có kết nối mạng.\nVui lòng kiểm tra Wi-Fi hoặc dữ liệu di động.',
  );
}
