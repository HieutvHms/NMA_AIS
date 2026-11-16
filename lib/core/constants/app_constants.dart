class AppConstants {
  AppConstants._();

  static const String appName = 'AIS AtoN Manager';
  static const String baseUrl = 'https://api.example.com/v1';

  // Timeout cấu hình thiết bị IoT 4G/AIS
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration configResponseTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyUserRole = 'user_role';
  static const String keyAllowedPorts = 'allowed_ports';

  // Validation
  static const int maxDeviceNameLength = 32;
  static const int mmsiLength = 9;
  static const int minUdpPort = 1;
  static const int maxUdpPort = 65535;
}

