import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

// Pill nhỏ gọn góc trên phải hiển thị khi đang tải dữ liệu AIS lần đầu.
class MapLoadingPill extends StatelessWidget {
  final bool visible;

  const MapLoadingPill({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: visible
          ? Container(
              key: const ValueKey('map_loading_pill'),
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderDark, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Đang tải AIS...',
                    style: AppTextStyles.s12w600(color: AppColors.textPrimary),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('map_loading_pill_empty')),
    );
  }
}

/// Banner nổi trượt từ phía trên (ngay dưới nút Danh sách) khi lỗi mạng / server.
class MapStatusBanner extends StatelessWidget {
  final String? errorMessage;
  final bool isNetworkError;
  final VoidCallback onRetry;

  const MapStatusBanner({
    super.key,
    required this.errorMessage,
    required this.isNetworkError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.trim().isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.25),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: hasError
          ? Container(
              key: ValueKey('map_error_${errorMessage}_$isNetworkError'),
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: const BoxDecoration(
                      color: AppColors.offlineBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNetworkError
                          ? Icons.wifi_off_rounded
                          : Icons.error_outline_rounded,
                      size: 18.r,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      errorMessage!.replaceAll('\n', ' '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s12w500(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 30.h,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: onRetry,
                      child: Text(
                        'Thử lại',
                        style: AppTextStyles.s12w600(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('map_error_empty')),
    );
  }
}
