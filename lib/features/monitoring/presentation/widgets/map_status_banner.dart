import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

/// Banner thông báo các trạng thái trên bản đồ: Đang tải lần đầu, Trống vùng nhìn, Lỗi / Mất mạng.
class MapStatusBanner extends StatelessWidget {
  final bool isInitialLoading;
  final bool isEmptyInView;
  final String? errorMessage;
  final bool isNetworkError;
  final VoidCallback onRetry;

  const MapStatusBanner({
    super.key,
    required this.isInitialLoading,
    required this.isEmptyInView,
    required this.errorMessage,
    required this.isNetworkError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading) {
      return _buildCard(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Đang tải dữ liệu đối tượng AIS...',
              style: AppTextStyles.s13w500(color: AppColors.textPrimary),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return _buildCard(
        borderColor: AppColors.error.withValues(alpha: 0.4),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: AppColors.offlineBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 20.r,
                color: AppColors.error,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                errorMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s12w500(color: AppColors.textPrimary),
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
          ],
        ),
      );
    }

    if (isEmptyInView) {
      return _buildCard(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_off_outlined,
              size: 18.r,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                'Không có đối tượng AIS trong vùng nhìn hiện tại.',
                style: AppTextStyles.s12w500(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCard({required Widget child, Color? borderColor}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor ?? AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
