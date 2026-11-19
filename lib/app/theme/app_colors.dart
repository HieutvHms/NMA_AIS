import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 1. BRAND COLORS
  static const Color primary = Color(0xFF1B63C6);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFE8F1FC);
  static const Color textAppbar = Color(0xFF0F2F66);

  // 2. BACKGROUNDS & SURFACES
  static const Color background = Color(0xFFEAF1F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // 4. BORDERS & DIVIDERS
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFF1F5F9);

  // 5. STATUS & AIS DOMAIN (Nghiệp vụ giám sát thiết bị)
  static const Color online = Color(0xFF16A34A);
  static const Color onlineBg = Color(0xFFDCFCE7);
  static const Color offline = Color(0xFFDC2626);
  static const Color offlineBg = Color(0xFFFEE2E2);
  static const Color maintenanceBg = Color(0xFFFFEDD5);

  // 6. COMMON SHORTHANDS
  static const Color success = online;
  static const Color error = offline;
  static const Color info = Color(0xFF0284C7);
  static const Color warning = Color(0xFFD97706);
  static const Color alertWarning = warning;
  static const Color alertRed = error;
  static const Color confirmDelete = error;
  static const Color dashboardSuccess = success;
}
