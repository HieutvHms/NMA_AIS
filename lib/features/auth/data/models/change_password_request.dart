/// Model request cho API `POST /user/change-password`.
class ChangePasswordRequest {
  final String username;
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.username,
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}

