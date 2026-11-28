import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';

class OverviewKpiMetric {
  final Color dotColor;
  final String label;

  const OverviewKpiMetric({required this.dotColor, required this.label});
}

class OverviewKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String title;
  final List<OverviewKpiMetric> metrics;
  final bool hasError;
  final VoidCallback onTap;
  final String? bannerAsset;

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
    this.bannerAsset,
  });

  String get _formattedCount {
    if (hasError && count == 0) return '--';
    if (count > 0 && count < 10) return count.toString().padLeft(2, '0');
    return count.toString();
  }

  String get _semanticsLabel {
    final metricText = metrics.map((m) => m.label).join(', ');
    if (metricText.isEmpty) return '$_formattedCount $title';
    return '$_formattedCount $title. $metricText';
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16.r);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: _semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: hasError
                  ? AppColors.error.withValues(alpha: 0.35)
                  : AppColors.borderDark,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBanner(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formattedCount,
                            style: AppTextStyles.s16w600(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.s13w600(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderDark.withValues(alpha: 0.6),
                      ),
                      SizedBox(height: 6.h),
                      for (int i = 0; i < metrics.length; i++) ...[
                        if (i > 0) SizedBox(height: 6.h),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 56.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bannerAsset != null)
            Image.asset(
              bannerAsset!,
              fit: BoxFit.cover,
              cacheWidth: 300,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => ColoredBox(color: iconBgColor),
            )
          else
            ColoredBox(color: iconBgColor),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 14.w),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //         width: 40.r,
          //         height: 40.r,
          //         alignment: Alignment.center,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withValues(alpha: 0.85),
          //           borderRadius: BorderRadius.circular(12.r),
          //         ),
          //         child: Icon(icon, color: iconColor, size: 22.r),
          //       ),
          //       Icon(Icons.chevron_right_rounded, size: 22.r, color: iconColor),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
