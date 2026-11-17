import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String role;
  final String? accessToken;
  final String? refreshToken;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,

    this.accessToken,
    this.refreshToken,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, username, role, accessToken, refreshToken];
}
