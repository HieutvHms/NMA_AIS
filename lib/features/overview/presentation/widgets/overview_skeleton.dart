import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/commom/skeleton/app_skeleton.dart';
import '../../../../app/theme/app_colors.dart';

/// Khung skeleton shimmer hiển thị khi màn hình Tổng quan đang tải dữ liệu lần đầu.
class OverviewSkeleton extends StatelessWidget {
  const OverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _kpiSkeleton()),
              SizedBox(width: 12.w),
              Expanded(child: _kpiSkeleton()),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 196.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.border),
            ),
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSkeletonBox(width: 110.w, height: 15.h),
                    const Spacer(),
                    AppSkeletonBox(width: 78.w, height: 14.h),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: AppSkeletonBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          AppSkeletonBox(width: 96.w, height: 16.h),
          SizedBox(height: 10.h),
          const AppSkeletonCardItem(
            showStatusBadge: false,
            subtitleLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _kpiSkeleton() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 38.r, height: 38.r, borderRadius: 11),
          SizedBox(height: 12.h),
          AppSkeletonBox(width: 52.w, height: 28.h),
          SizedBox(height: 8.h),
          AppSkeletonBox(width: 96.w, height: 14.h),
          SizedBox(height: 10.h),
          AppSkeletonBox(width: 84.w, height: 11.h),
          SizedBox(height: 6.h),
          AppSkeletonBox(width: 78.w, height: 11.h),
        ],
      ),
    );
  }
}
