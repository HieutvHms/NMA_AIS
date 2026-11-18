import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'secure_storege.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  final SecureStorage? _secureStorage;

  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  LocalStorage(this._prefs, {SecureStorage? secureStorage})
    : _secureStorage = secureStorage {
    _cachedAccessToken = _prefs.getString(AppConstants.keyAccessToken);
    _cachedRefreshToken = _prefs.getString(AppConstants.keyRefreshToken);
  }

  /// Nạp token từ SecureStorage vào bộ nhớ đệm khi khởi động app
  /// và di chuyển dữ liệu cũ từ SharedPreferences (nếu có) sang SecureStorage.
  Future<void> init() async {
    final secure = _secureStorage;
    if (secure == null) return;

    var secureAccess = await secure.read(AppConstants.keyAccessToken);
    var secureRefresh = await secure.read(AppConstants.keyRefreshToken);

    // Di chuyển token cũ từ SharedPreferences sang SecureStorage (1 lần)
    final legacyAccess = _prefs.getString(AppConstants.keyAccessToken);
    final legacyRefresh = _prefs.getString(AppConstants.keyRefreshToken);

    if ((secureAccess == null || secureAccess.isEmpty) &&
        legacyAccess != null &&
        legacyAccess.isNotEmpty) {
      secureAccess = legacyAccess;
      await secure.write(AppConstants.keyAccessToken, legacyAccess);
    }
    if ((secureRefresh == null || secureRefresh.isEmpty) &&
        legacyRefresh != null &&
        legacyRefresh.isNotEmpty) {
      secureRefresh = legacyRefresh;
      await secure.write(AppConstants.keyRefreshToken, legacyRefresh);
    }

    if (legacyAccess != null) {
      await _prefs.remove(AppConstants.keyAccessToken);
    }
    if (legacyRefresh != null) {
      await _prefs.remove(AppConstants.keyRefreshToken);
    }

    _cachedAccessToken = secureAccess;
    _cachedRefreshToken = secureRefresh;
  }

  Future<void> saveToken(String token) async {
    _cachedAccessToken = token;
    if (_secureStorage != null) {
      await _secureStorage.write(AppConstants.keyAccessToken, token);
    } else {
      await _prefs.setString(AppConstants.keyAccessToken, token);
    }
  }

  String? getToken() => _cachedAccessToken;

  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    if (_secureStorage != null) {
      await _secureStorage.write(AppConstants.keyRefreshToken, token);
    } else {
      await _prefs.setString(AppConstants.keyRefreshToken, token);
    }
  }

  String? getRefreshToken() => _cachedRefreshToken;

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() => _prefs.getString(AppConstants.keyUserId);

  Future<void> saveUsername(String username) async {
    await _prefs.setString(AppConstants.keyUsername, username);
  }

  String? getUsername() => _prefs.getString(AppConstants.keyUsername);

  Future<void> saveRole(String role) async {
    await _prefs.setString(AppConstants.keyUserRole, role);
  }

  String? getRole() => _prefs.getString(AppConstants.keyUserRole);

  Future<void> saveAllowedPorts(List<int> ports) async {
    await _prefs.setStringList(
      AppConstants.keyAllowedPorts,
      ports.map((e) => e.toString()).toList(),
    );
  }

  List<int> getAllowedPorts() {
    final raw = _prefs.getStringList(AppConstants.keyAllowedPorts) ?? [];
    return raw.map((e) => int.tryParse(e)).whereType<int>().toList();
  }

  Future<void> clearSession() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    if (_secureStorage != null) {
      await _secureStorage.delete(AppConstants.keyAccessToken);
      await _secureStorage.delete(AppConstants.keyRefreshToken);
    }
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUsername);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyAllowedPorts);
  }
}
