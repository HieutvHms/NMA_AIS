import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String role; // 'admin' | 'user'
  final List<int> allowedPorts;
  final bool canConfigureDevice;
  final bool canConfigureBuoy;
  final bool canViewRoutes;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.allowedPorts,
    this.canConfigureDevice = true,
    this.canConfigureBuoy = false,
    this.canViewRoutes = true,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
        id,
        username,
        role,
        allowedPorts,
        canConfigureDevice,
        canConfigureBuoy,
        canViewRoutes,
      ];
}

