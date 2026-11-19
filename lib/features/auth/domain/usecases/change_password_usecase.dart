import '../repositories/auth_repository.dart';

/// UseCase đổi mật khẩu tài khoản hiện tại (`POST /user/change-password`).
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

