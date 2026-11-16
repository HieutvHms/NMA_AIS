import '../../../core/storage/local_storage.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import 'models/user_model.dart';

class AuthRemoteDataSource implements AuthRepository {
  final LocalStorage _localStorage;

  AuthRemoteDataSource(this._localStorage);

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    // Mock xử lý đăng nhập khi chưa có Backend
    await Future.delayed(const Duration(milliseconds: 600));

    final isAdmin = username.toLowerCase() == 'admin';
    final user = UserModel(
      id: isAdmin ? '1' : '2',
      username: username,
      role: isAdmin ? 'admin' : 'user',
      allowedPorts: isAdmin ? const [5001, 5002, 5003] : const [5001, 5002],
      canConfigureDevice: true,
      canConfigureBuoy: isAdmin,
      canViewRoutes: true,
    );

    await _localStorage.saveToken('mock_token_${user.id}');
    await _localStorage.saveRole(user.role);
    await _localStorage.saveAllowedPorts(user.allowedPorts);

    return user;
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearSession();
  }
}

