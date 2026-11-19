import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  Future<bool> refreshToken();

  Future<void> logout({bool callRemote = true});

  Future<UserEntity?> getCurrentUser();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

