import 'package:equatable/equatable.dart';

class MemberEntity extends Equatable {
  final String id;
  final int userId;
  final String username;
  final String? password;
  final String name;
  final String email;
  final String phone;
  final int role;
  final int parentId;
  final String udpPort;
  final DateTime? createdAt;

  const MemberEntity({
    this.id = '',
    this.userId = 0,
    required this.username,
    this.password,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 1,
    this.parentId = 0,
    this.udpPort = '',
    this.createdAt,
  });

  String get displayName {
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed : username;
  }

  String get initials {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  MemberEntity copyWith({
    String? id,
    int? userId,
    String? username,
    String? password,
    String? name,
    String? email,
    String? phone,
    int? role,
    int? parentId,
    String? udpPort,
    DateTime? createdAt,
  }) {
    return MemberEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      parentId: parentId ?? this.parentId,
      udpPort: udpPort ?? this.udpPort,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    password,
    name,
    email,
    phone,
    role,
    parentId,
    udpPort,
    createdAt,
  ];
}
