import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 1. BRAND COLORS (AIS Maritime Navy)
  static const Color primary = Color(0xFF1B63C6); // Xanh dương chủ đạo
  static const Color primaryDark = Color(0xFF0D47A1); // Xanh đậm nhấn / bóng đổ
  static const Color primaryLight = Color(
    0xFFE8F1FC,
  ); // Xanh nền nhạt (pill, badge, hover)

  // 2. BACKGROUNDS & SURFACES
  static const Color background = Color(0xFFEAF1F9);
  static const Color surface = Color(0xFFFFFFFF); // Nền thẻ card, popup, dialog
  static const Color surfaceSecondary = Color(
    0xFFF8FAFC,
  ); // Nền xen kẽ bảng, header phụ

  // 3. TEXTS
  static const Color textPrimary = Color(0xFF0F172A); // Chữ chính (Slate 900)
  static const Color textSecondary = Color(
    0xFF475569,
  ); // Chữ phụ, mô tả (Slate 600)
  static const Color textMuted = Color(
    0xFF94A3B8,
  ); // Placeholder, hint (Slate 400)
  static const Color textWhite = Color(0xFFFFFFFF); // Chữ trên nền màu

  // 4. BORDERS & DIVIDERS
  static const Color border = Color(
    0xFFE2E8F0,
  ); // Viền thẻ, đường kẻ bảng (Slate 200)
  static const Color borderDark = Color(
    0xFFCBD5E1,
  ); // Viền ô input, viền nổi (Slate 300)
  static const Color divider = Color(
    0xFFF1F5F9,
  ); // Đường ngăn cách item danh sách

  // 5. STATUS & AIS DOMAIN (Nghiệp vụ giám sát thiết bị)
  static const Color online = Color(0xFF16A34A); // Thiết bị Online (Green)
  static const Color onlineBg = Color(0xFFDCFCE7); // Badge nền Online
  static const Color offline = Color(0xFFDC2626); // Thiết bị Offline (Red)
  static const Color offlineBg = Color(0xFFFEE2E2); // Badge nền Offline
  static const Color maintenanceBg = Color(0xFFFFEDD5); // Badge nền bảo trì

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
