class AppConstants {
  AppConstants._();

  static const String appName = 'AIS AtoN Manager';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://api.example.com/v1';

  // Timeout cấu hình thiết bị IoT 4G/AIS
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration configResponseTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyUserRole = 'user_role';
  static const String keyAllowedPorts = 'allowed_ports';

  // Validation
  static const int maxDeviceNameLength = 32;
  static const int mmsiLength = 9;
  static const int minUdpPort = 1;
  static const int maxUdpPort = 65535;

  // Cấu hình bản đồ Giám sát AIS (Google Maps)
  static const Duration mapAutoRefreshInterval = Duration(seconds: 10);
  static const Duration mapCameraDebounce = Duration(milliseconds: 500);
  static const double vietnamCenterLat = 15.8000;
  static const double vietnamCenterLng = 108.5000;
  static const double vietnamDefaultZoom = 5.8;
  static const bool enableMapClustering = false;
  static const double mapClusterDisableZoom = 10.0;
  static const double mapTargetFocusZoom = 14.0;
  static const int mockAisTargetCount = 2000;
}
