import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_endpoints.dart';

class AppConfig {
  AppConfig._();

  static Future<void> init({String envFile = '.env'}) async {
    try {
      await dotenv.load(fileName: envFile);
    } catch (_) {}
  }

  // Auth Base URL
  static String get authBaseUrl {
    final url = dotenv.get(
      'AUTH_BASE_URL',
      fallback: 'http://192.168.1.9:9800',
    );
    return url.replaceAll(RegExp(r'/auth(/login)?/?$'), '');
  }

  // Auth Full Endpoint URLs kết hợp với ApiEndpoints
  static String get loginUrl => '$authBaseUrl${ApiEndpoints.login}';
  static String get refreshTokenUrl =>
      '$authBaseUrl${ApiEndpoints.refreshToken}';
  static String get logoutUrl => '$authBaseUrl${ApiEndpoints.logout}';

  // Device Management
  static String get deviceQueryUrl => '$authBaseUrl${ApiEndpoints.deviceQuery}';
  static String get deviceUpdateUrl =>
      '$authBaseUrl${ApiEndpoints.deviceUpdate}';

  // User / Member Management
  static String get userQueryUrl => '$authBaseUrl${ApiEndpoints.userQuery}';
  static String get userUpdateUrl => '$authBaseUrl${ApiEndpoints.userUpdate}';
  static String get changePasswordUrl =>
      '$authBaseUrl${ApiEndpoints.changePassword}';

  // API Base URLs
  static String get managerBaseUrl => dotenv.get(
    'MANAGER_BASE_URL',
    fallback: 'http://thapi.hmstech.vn/manager',
  );

  static String get processDataBaseUrl => dotenv.get(
    'PROCESS_DATA_BASE_URL',
    fallback: 'http://thapi.hmstech.vn/processdata',
  );

  static String get reportBaseUrl =>
      dotenv.get('REPORT_BASE_URL', fallback: 'http://thapi.hmstech.vn/report');

  // Realtime & Protocol URLs
  static String get realtimeType =>
      dotenv.get('REALTIME_TYPE', fallback: 'POLLING');

  static String get mqttBroker => dotenv.get('MQTT_BROKER', fallback: '');

  static int get mqttPort =>
      int.tryParse(dotenv.get('MQTT_PORT', fallback: '1883')) ?? 1883;

  static String get wsUrl => dotenv.get('WS_URL', fallback: '');

  // Môi trường
  static String get environment =>
      dotenv.get('ENVIRONMENT', fallback: 'development');

  static bool get isDevelopment => environment.toLowerCase() == 'development';
  static bool get isProduction => environment.toLowerCase() == 'production';
}
