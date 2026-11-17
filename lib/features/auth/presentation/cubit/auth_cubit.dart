import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const Unauthenticated()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      emit(const Unauthenticated(
        errorMessage: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
      ));
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
    await _logoutUseCase();
    emit(Unauthenticated(errorMessage: reason));
  }

  Future<void> logout() async {
    await _logoutUseCase();
    emit(const Unauthenticated());
  }
}
