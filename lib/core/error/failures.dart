import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Máy chủ đang gặp sự cố. Vui lòng thử lại.',
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Không có kết nối mạng.',
    super.code,
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
    super.code = 401,
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Bạn không có quyền thực hiện thao tác này.',
    super.code = 403,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Không tìm thấy dữ liệu.',
    super.code = 404,
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure({
    required super.message,
    this.errors = const {},
    super.code = 422,
  });

  @override
  List<Object?> get props => [...super.props, errors];
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Lỗi truy xuất bộ nhớ tạm.',
    super.code,
  });
}

class ConfigTimeoutFailure extends Failure {
  const ConfigTimeoutFailure({
    super.message = 'Không nhận được phản hồi từ thiết bị.',
    super.code,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Tài khoản không có quyền thực hiện thao tác này.',
    super.code,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Đã xảy ra lỗi không mong muốn.',
    super.code,
  });
}
