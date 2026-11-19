import '../../domain/entities/member_entity.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    super.id,
    super.userId,
    required super.username,
    super.password,
    super.name,
    super.email,
    super.phone,
    super.role,
    super.parentId,
    super.udpPort,
    super.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id']?.toString() ?? '',
      userId: _parseInt(json['userId']),
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: _parseInt(json['role'], fallback: 1),
      parentId: _parseInt(json['parentId']),
      udpPort: json['udpPort']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  factory MemberModel.fromEntity(MemberEntity entity) {
    return MemberModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      password: entity.password,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      parentId: entity.parentId,
      udpPort: entity.udpPort,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toCreateJson(int userId) {
    return {
      'userId': userId,
      'username': username.trim(),
      'password': password ?? '',
      'email': email.trim(),
      'phone': phone.trim(),
      'name': name.trim(),
      'udpPort': udpPort.trim(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'userId': userId,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'udpPort': udpPort.trim(),
    };
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
