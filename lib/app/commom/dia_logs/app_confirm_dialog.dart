import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final Color? confirmTextColor;
  final bool barrierDismissible;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.cancelText = 'Huỷ',
    this.confirmText = 'Xác nhận',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.confirmTextColor,
    this.barrierDismissible = true,
  });

  /// Hiển thị dialog xác nhận tuỳ chỉnh hoàn toàn.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String cancelText = 'Huỷ',
    String confirmText = 'Xác nhận',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? confirmTextColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AppConfirmDialog(
        title: title,
        subtitle: subtitle,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Template: Xoá một item
  static Future<bool?> showDelete(
    BuildContext context, {
    String itemName = 'mục này',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Xoá $itemName',
      subtitle:
          'Bạn có chắc muốn xoá $itemName không?\nHành động này không thể hoàn tác.',
      confirmText: 'Xoá',
      confirmColor: AppColors.confirmDelete,
      confirmTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: false,
    );
  }

  /// Template: Đăng xuất
  static Future<bool?> showLogout(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Đăng xuất',
      subtitle: 'Bạn có chắc muốn đăng xuất khỏi tài khoản không?',
      confirmText: 'Đăng xuất',
      confirmColor: AppColors.alertRed,
      confirmTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: false,
    );
  }

  /// Template: Huỷ thay đổi
  static Future<bool?> showDiscardChanges(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Huỷ thay đổi',
      subtitle: 'Mọi thay đổi sẽ bị mất. Bạn có muốn tiếp tục không?',
      cancelText: 'Tiếp tục chỉnh sửa',
      confirmText: 'Huỷ thay đổi',
      confirmColor: AppColors.alertWarning,
      confirmTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: false,
    );
  }

  /// Template: Cảnh báo tuỳ chỉnh
  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    required String subtitle,
    String confirmText = 'Tiếp tục',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: title,
      subtitle: subtitle,
      confirmText: confirmText,
      confirmColor: AppColors.alertWarning,
      confirmTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

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
                  ? Colors.white.withValues(alpha: 0.12)
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
              // Title
              Text(
                title,
                style: AppTextStyles.s16w600(color: textColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              // Subtitle
              Text(
                subtitle,
                style: AppTextStyles.s13w500(color: subtextColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Buttons
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: _DialogOutlinedButton(
                      text: cancelText,
                      borderColor: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.border,
                      textColor: textColor,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Confirm
                  Expanded(
                    child: _DialogFilledButton(
                      text: confirmText,
                      backgroundColor: confirmColor ?? AppColors.primary,
                      textColor: confirmTextColor ?? Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogOutlinedButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _DialogOutlinedButton({
    required this.text,
    required this.borderColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: AppTextStyles.s14w500(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DialogFilledButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _DialogFilledButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: AppTextStyles.s14w600(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
