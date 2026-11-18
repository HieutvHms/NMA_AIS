import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

/// Dialog thông báo dùng chung toàn app (1 nút: OK / Tiếp tục).
///
/// Cách dùng nhanh:
/// ```dart
/// await AppInfoDialog.showSuccess(context, title: '...', message: '...');
/// await AppInfoDialog.showError(context, title: '...', message: '...');
/// await AppInfoDialog.show(context, title: '...', message: '...');
/// ```
class AppInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Widget? icon;
  final bool barrierDismissible;

  const AppInfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onButtonPressed,
    this.buttonColor,
    this.buttonTextColor,
    this.icon,
    this.barrierDismissible = true,
  });

  // ─────────────────────── static show ───────────────────────

  /// Hiển thị dialog thông báo tuỳ chỉnh hoàn toàn.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
    Color? buttonColor,
    Color? buttonTextColor,
    Widget? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppInfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        buttonColor: buttonColor,
        buttonTextColor: buttonTextColor,
        icon: icon,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // ─────────────────────── templates ───────────────────────

  /// Template: Thông báo thành công
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Tiếp tục',
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: AppColors.dashboardSuccess,
      buttonTextColor: Colors.white,
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: AppColors.dashboardSuccess,
        size: 48.sp,
      ),
      onButtonPressed: onButtonPressed,
    );
  }

  /// Template: Thông báo lỗi
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Đóng',
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: AppColors.alertRed,
      buttonTextColor: Colors.white,
      icon: Icon(
        Icons.error_outline_rounded,
        color: AppColors.alertRed,
        size: 48.sp,
      ),
      onButtonPressed: onButtonPressed,
    );
  }

  /// Template: Thông báo thông tin
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Hiểu rồi',
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: AppColors.primary,
      buttonTextColor: Colors.white,
      icon: Icon(
        Icons.info_outline_rounded,
        color: AppColors.primary,
        size: 48.sp,
      ),
      onButtonPressed: onButtonPressed,
    );
  }

  /// Template: Thông báo cảnh báo
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Đã hiểu',
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: AppColors.alertWarning,
      buttonTextColor: Colors.white,
      icon: Icon(
        Icons.warning_amber_rounded,
        color: AppColors.alertWarning,
        size: 48.sp,
      ),
      onButtonPressed: onButtonPressed,
    );
  }

  /// Template: Thông báo người dùng bị đá ra (session kicked)
  static Future<void> showSessionExpired(
    BuildContext context, {
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context,
      title: 'Phiên đăng nhập hết hạn',
      message:
          'Tài khoản của bạn đã đăng nhập ở thiết bị khác. Vui lòng đăng nhập lại.',
      buttonText: 'Đăng nhập lại',
      buttonColor: AppColors.primary,
      buttonTextColor: Colors.white,
      barrierDismissible: false,
      onButtonPressed: onButtonPressed,
    );
  }

  // ─────────────────────── build ───────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon (nếu có)
              if (icon != null) ...[icon!, SizedBox(height: 12.h)],
              // Title
              Text(
                title,
                style: AppTextStyles.s16w600(color: textColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              // Message
              Text(
                message,
                style: AppTextStyles.s14w400(color: subtextColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Button
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onButtonPressed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? AppColors.primary,
                    foregroundColor: buttonTextColor ?? Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    buttonText,
                    style: AppTextStyles.s14w500(
                      color: buttonTextColor ?? Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
