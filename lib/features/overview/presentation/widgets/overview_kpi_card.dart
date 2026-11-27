import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';

class OverviewKpiMetric {
  final Color dotColor;
  final String label;

  const OverviewKpiMetric({required this.dotColor, required this.label});
}

/// Thẻ KPI trên màn hình Tổng quan (Thiết bị 4G / Tàu & Phao AIS).
class OverviewKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String title;
  final List<OverviewKpiMetric> metrics;
  final bool hasError;
  final VoidCallback onTap;

  const OverviewKpiCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.title,
    required this.metrics,
    this.hasError = false,
    required this.onTap,
  });

  String get _formattedCount {
    if (hasError && count == 0) return '--';
    if (count > 0 && count < 10) return count.toString().padLeft(2, '0');
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: hasError
              ? AppColors.error.withValues(alpha: 0.35)
              : AppColors.borderDark,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 22.r),
                ),
                SizedBox(height: 12.h),
                Text(
                  _formattedCount,
                  style: AppTextStyles.headlineMedium().copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s14w600(color: AppColors.textPrimary),
                ),
                SizedBox(height: 8.h),
                for (int i = 0; i < metrics.length; i++) ...[
                  if (i > 0) SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: BoxDecoration(
                          color: metrics[i].dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          metrics[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.s12w500(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
