import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const Unauthenticated());

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      emit(const Unauthenticated(
        errorMessage: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu',
      ));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        username: username.trim(),
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(Unauthenticated(errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }
}

