class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Device Management
  static const String deviceQuery = '/device/query';
  static const String deviceUpdate = '/device/update';

  // Device Status
  static const String deviceStatus = '/device/status';

  // User / Member Management
  static const String userQuery = '/user/query';
  static const String userUpdate = '/user/update';
  static const String changePassword = '/user/change-password';
  static const String resetPassword = '/user/reset-password';

  // Giám sát bản đồ AIS
  static const String aisData = '/ais/data';
}
