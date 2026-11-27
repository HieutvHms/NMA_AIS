import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import 'map_status_banner.dart';

/// Thanh nổi phía trên bản đồ: nút Danh sách (trái), Status Pill đang tải (phải),
/// và Banner lỗi mạng/server trượt mượt bên dưới khi có lỗi.
class MapTopOverlayBar extends StatelessWidget {
  final bool isInitialLoading;
  final String? errorMessage;
  final bool isNetworkError;
  final VoidCallback onOpenListTap;
  final VoidCallback onRetry;

  const MapTopOverlayBar({
    super.key,
    required this.isInitialLoading,
    required this.errorMessage,
    required this.isNetworkError,
    required this.onOpenListTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 36.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      surfaceTintColor: Colors.transparent,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.14),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: onOpenListTap,
                    icon: SvgPicture.asset(
                      'assets/icons/map/ic_list.svg',
                      height: 12.h,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Danh sách',
                      style: AppTextStyles.s13w600(color: AppColors.primary),
                    ),
                  ),
                ),
                const Spacer(),
                MapLoadingPill(visible: isInitialLoading),
              ],
            ),
            MapStatusBanner(
              errorMessage: isInitialLoading ? null : errorMessage,
              isNetworkError: isNetworkError,
              onRetry: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
