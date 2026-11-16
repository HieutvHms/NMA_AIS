import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? validateDeviceName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên thiết bị không được để trống';
    }
    if (value.trim().length > AppConstants.maxDeviceNameLength) {
      return 'Tên thiết bị tối đa ${AppConstants.maxDeviceNameLength} ký tự';
    }
    return null;
  }

  static String? validateUdpPort(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'UDP Port không được để trống' : null;
    }
    final port = int.tryParse(value.trim());
    if (port == null ||
        port < AppConstants.minUdpPort ||
        port > AppConstants.maxUdpPort) {
      return 'Port phải là số từ ${AppConstants.minUdpPort} đến ${AppConstants.maxUdpPort}';
    }
    return null;
  }

  static String? validateMmsi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MMSI không được để trống';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'MMSI chỉ được chứa ký tự số';
    }
    if (trimmed.length != AppConstants.mmsiLength) {
      return 'MMSI phải gồm đúng ${AppConstants.mmsiLength} chữ số';
    }
    return null;
  }
}

