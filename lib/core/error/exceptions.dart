class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  const ValidationException({required this.message, this.errors = const {}});

  @override
  String toString() => 'ValidationException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Phiên đăng nhập hết hạn.'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;

  const ForbiddenException({this.message = 'Bạn không có quyền truy cập.'});

  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({this.message = 'Không tìm thấy dữ liệu.'});

  @override
  String toString() => 'NotFoundException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Không có kết nối mạng.'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Lỗi bộ nhớ đệm.'});

  @override
  String toString() => 'CacheException: $message';
}

class ConfigTimeoutException implements Exception {
  final String message;

  const ConfigTimeoutException({
    this.message = 'Không nhận được phản hồi từ thiết bị.',
  });

  @override
  String toString() => 'ConfigTimeoutException: $message';
}
