import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.keyAccessToken, token);
  }

  String? getToken() => _prefs.getString(AppConstants.keyAccessToken);

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.keyRefreshToken, token);
  }

  String? getRefreshToken() => _prefs.getString(AppConstants.keyRefreshToken);

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
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUsername);
    await _prefs.remove(AppConstants.keyUserRole);
    await _prefs.remove(AppConstants.keyAllowedPorts);
  }
}

