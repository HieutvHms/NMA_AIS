import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_refresh_coordinator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/change_password_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;
  final TokenRefreshCoordinator _refreshCoordinator;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
    required TokenRefreshCoordinator refreshCoordinator,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage,
       _refreshCoordinator = refreshCoordinator;

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
    final result = await _refreshCoordinator.refresh();

    if (result.isSuccess) {
      return true;
    }

    if (result.isInvalidSession) {
      return false;
    }

    // Lỗi mạng / 5xx: ném Failure để tầng trên phân biệt với phiên hết hạn,
    // KHÔNG xóa phiên đã lưu.
    throw ErrorMapper.map(
      result.dioException ??
          NetworkException(
            message: result.message ?? 'Không có kết nối mạng.',
          ),
    );
  }

  @override
  Future<void> logout({bool callRemote = true}) async {
    try {
      if (callRemote) {
        // Chờ request refresh đang chạy (nếu có) hoàn tất để gửi refreshToken mới nhất
        await _refreshCoordinator.waitForPendingRefresh();
        final refreshToken = _localStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _remoteDataSource.logout(refreshToken: refreshToken);
        }
      }
    } catch (_) {
    } finally {
      await _localStorage.clearSession();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _localStorage.getToken();
    final refreshToken = _localStorage.getRefreshToken();
    if ((token == null || token.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      return null;
    }

    final username = _localStorage.getUsername() ?? 'admin';
    final role = _localStorage.getRole() ?? '0';
    final userId = _localStorage.getUserId() ?? '1';

    return UserModel(
      id: userId,
      username: username,
      role: role,
      accessToken: token,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final username = _localStorage.getUsername()?.trim() ?? '';
    if (username.isEmpty) {
      throw const ServerException(
        message: 'Không tìm thấy thông tin tài khoản hiện tại.',
      );
    }

    await _remoteDataSource.changePassword(
      ChangePasswordRequest(
        username: username,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }
}
