class ApiEndpoints {
  ApiEndpoints._();

  //  Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';

  // Device Management
  static const String deviceQuery = '/device/query';
  static const String deviceUpdate = '/device/update';
}
