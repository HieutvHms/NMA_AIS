import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      // Lưu phiên đăng nhập
      if (userModel.accessToken != null) {
        await _localStorage.saveToken(userModel.accessToken!);
      }
      if (userModel.refreshToken != null) {
        await _localStorage.saveRefreshToken(userModel.refreshToken!);
      }
      if (userModel.id.isNotEmpty) {
        await _localStorage.saveUserId(userModel.id);
      }
      await _localStorage.saveUsername(userModel.username);
      await _localStorage.saveRole(userModel.role);

      return userModel;
    } catch (e) {
      final failure = ErrorMapper.map(e);
      throw failure;
    }
  }

  @override
  Future<bool> refreshToken() async {
    final oldAccessToken = _localStorage.getToken();
    final oldRefreshToken = _localStorage.getRefreshToken();

    if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
      await _localStorage.clearSession();
      return false;
    }

    try {
      final data = await _remoteDataSource.refreshToken(
        accessToken: oldAccessToken ?? '',
        refreshToken: oldRefreshToken,
      );

      final newAccessToken = data['accessToken']?.toString() ?? '';
      final newRefreshToken = data['refreshToken']?.toString() ?? '';

      if (newAccessToken.isNotEmpty) {
        await _localStorage.saveToken(newAccessToken);
        if (newRefreshToken.isNotEmpty) {
          await _localStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      await _localStorage.clearSession();
      return false;
    } catch (_) {
      await _localStorage.clearSession();
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
    } finally {
      await _localStorage.clearSession();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _localStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final username = _localStorage.getUsername() ?? 'admin';
    final role = _localStorage.getRole() ?? 'admin';
    final userId = _localStorage.getUserId() ?? '1';
    final refreshToken = _localStorage.getRefreshToken();

    return UserModel(
      id: userId,
      username: username,
      role: role,
      accessToken: token,
      refreshToken: refreshToken,
    );
  }
}
