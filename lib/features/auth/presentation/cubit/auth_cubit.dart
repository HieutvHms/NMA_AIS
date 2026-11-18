import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial());

  /// Kiểm tra phiên khi mở lại app:
  /// - Nếu có refresh token đã lưu -> gọi POST /auth/refresh để lấy cặp token mới.
  /// - Nếu INVALID_REFRESH_TOKEN -> xóa phiên và yêu cầu đăng nhập lại.
  /// - Nếu lỗi mạng -> giữ nguyên phiên đã lưu để người dùng tiếp tục sử dụng,
  ///   AuthInterceptor sẽ tự động refresh khi có mạng trở lại.
  Future<void> checkAuthStatus() async {
    try {
      final cachedUser = await _getCurrentUserUseCase();
      if (cachedUser == null ||
          cachedUser.refreshToken == null ||
          cachedUser.refreshToken!.isEmpty) {
        emit(const Unauthenticated());
        return;
      }

      try {
        final refreshed = await _refreshTokenUseCase();
        if (!refreshed) {
          emit(const Unauthenticated());
          return;
        }
        final updatedUser = await _getCurrentUserUseCase();
        if (updatedUser != null) {
          emit(Authenticated(updatedUser));
        } else {
          emit(const Unauthenticated());
        }
      } on Failure {
        // Lỗi mạng / server tạm thời: giữ phiên đã lưu theo tài liệu BE
        emit(Authenticated(cachedUser));
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      emit(
        const Unauthenticated(
          errorMessage: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
        ),
      );
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        username: username.trim(),
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      final failure = e is Failure ? e : ErrorMapper.map(e);
      emit(Unauthenticated(errorMessage: failure.message, failure: failure));
    }
  }

  /// Đăng xuất khi phiên làm việc hết hạn (được gọi từ Dio Interceptor)
  Future<void> forceLogout({String? reason}) async {
    await _logoutUseCase(callRemote: false);
    emit(Unauthenticated(errorMessage: reason));
  }

  Future<void> logout() async {
    await _logoutUseCase(callRemote: true);
    emit(const Unauthenticated());
  }
}
