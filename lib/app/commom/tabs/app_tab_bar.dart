import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

enum AppTabBarStyle { pill, underline }

class AppTabItem {
  final String label;
  final int? count;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool showBadgeIfZero;
  final IconData? icon;
  final String? svgAsset;

  const AppTabItem({
    required this.label,
    this.count,
    this.badgeColor,
    this.badgeTextColor,
    this.showBadgeIfZero = false,
    this.icon,
    this.svgAsset,
  });
}

/// Thanh Tab dùng chung toàn ứng dụng, hỗ trợ kiểu Pill (bo tròn trượt) và Underline.
class AppTabBar extends StatelessWidget {
  final List<AppTabItem> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? activeIndicatorColor;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final AppTabBarStyle tabStyle;
  final bool showBottomDivider;
  final EdgeInsetsGeometry? indicatorInsets;

  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.height,
    this.margin,
    this.borderRadius = 12.0,
    this.activeIndicatorColor,
    this.backgroundColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.tabStyle = AppTabBarStyle.pill,
    this.showBottomDivider = true,
    this.indicatorInsets,
  });

  @override
  Widget build(BuildContext context) {
    final isUnderline = tabStyle == AppTabBarStyle.underline;
    final indicatorColor = activeIndicatorColor ?? AppColors.primary;
    final effectiveLabelColor =
        labelColor ?? (isUnderline ? indicatorColor : Colors.white);
    final effectiveUnselectedColor =
        unselectedLabelColor ?? AppColors.textSecondary;

    final tabBar = TabBar(
      controller: controller,
      onTap: onTap,
      indicatorSize: TabBarIndicatorSize.tab,
      splashBorderRadius: BorderRadius.circular(borderRadius.r),
      dividerColor: isUnderline && showBottomDivider
          ? AppColors.border
          : Colors.transparent,
      dividerHeight: isUnderline && showBottomDivider ? 1.h : 0,
      indicator: isUnderline
          ? UnderlineTabIndicator(
              borderSide: BorderSide(color: indicatorColor, width: 2.5.h),
              borderRadius: BorderRadius.circular(2.r),
              insets: indicatorInsets ?? EdgeInsets.symmetric(horizontal: 16.w),
            )
          : BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular((borderRadius - 2).r),
              boxShadow: [
                BoxShadow(
                  color: indicatorColor.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      labelColor: effectiveLabelColor,
      unselectedLabelColor: effectiveUnselectedColor,
      labelStyle: AppTextStyles.s13w600(color: effectiveLabelColor),
      unselectedLabelStyle: AppTextStyles.s13w500(
        color: effectiveUnselectedColor,
      ),
      tabs: tabs.map((item) => _buildTab(item, isUnderline)).toList(),
    );

    if (isUnderline) {
      return Container(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        height: height ?? 42.h,
        child: tabBar,
      );
    }

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: height ?? 42.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE2E8F0).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: tabBar,
    );
  }

  Widget _buildTab(AppTabItem item, bool isUnderline) {
    final shouldShowBadge =
        item.count != null && (item.count! > 0 || item.showBadgeIfZero);

    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.svgAsset != null) ...[
            _buildSvgIcon(item.svgAsset!),
            SizedBox(width: 6.w),
          ] else if (item.icon != null) ...[
            Icon(item.icon, size: 17.r),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (shouldShowBadge) ...[
            SizedBox(width: 6.w),
            _buildBadge(item, isUnderline),
          ],
        ],
      ),
    );
  }

  Widget _buildSvgIcon(String assetPath) {
    return Builder(
      builder: (context) {
        final iconColor = IconTheme.of(context).color ?? AppColors.textPrimary;
        return SvgPicture.asset(
          assetPath,
          width: 16.r,
          height: 16.r,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      },
    );
  }

  Widget _buildBadge(AppTabItem item, bool isUnderline) {
    return Builder(
      builder: (context) {
        final themeColor = IconTheme.of(context).color ?? AppColors.textPrimary;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: item.badgeColor ?? themeColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '${item.count}',
            style: TextStyle(
              color:
                  item.badgeTextColor ??
                  (isUnderline ? themeColor : themeColor),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

