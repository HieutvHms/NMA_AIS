class ApiEndpoints {
  ApiEndpoints._();

  //  Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // Device Management
  static const String deviceQuery = '/device/query';
  static const String deviceUpdate = '/device/update';

  // User / Member Management
  static const String userQuery = '/user/query';
  static const String userUpdate = '/user/update';
}
