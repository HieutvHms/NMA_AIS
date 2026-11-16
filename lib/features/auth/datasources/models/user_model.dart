import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    required super.allowedPorts,
    super.canConfigureDevice,
    super.canConfigureBuoy,
    super.canViewRoutes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      allowedPorts: (json['allowedPorts'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toList() ??
          const [],
      canConfigureDevice: json['canConfigureDevice'] as bool? ?? true,
      canConfigureBuoy: json['canConfigureBuoy'] as bool? ?? false,
      canViewRoutes: json['canViewRoutes'] as bool? ?? true,
    );
  }
}

