import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app/theme/text_style.dart';

// Cụm thanh thông tin nổi phía trên bản đồ: Bộ đếm đối tượng trong vùng nhìn & Nút mở Danh sách / Tìm kiếm.
class MapTopOverlayBar extends StatelessWidget {
  final int totalInView;
  final bool isRefreshing;
  final VoidCallback onOpenListTap;

  const MapTopOverlayBar({
    super.key,
    required this.totalInView,
    required this.isRefreshing,
    required this.onOpenListTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
        child: Row(
          children: [
            SizedBox(
              height: 36.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.14),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  side: const BorderSide(color: AppColors.primary, width: 0.8),
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
          ],
        ),
      ),
    );
  }
}
