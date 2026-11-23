import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AppUnderlineTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? dividerColor;

  const AppUnderlineTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedActive = activeColor ?? AppColors.primary;
    final resolvedInactive = inactiveColor ?? AppColors.textPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        border: Border(
          bottom: BorderSide(color: dividerColor ?? AppColors.border, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: onTap,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 14.w),
        labelColor: resolvedActive,
        unselectedLabelColor: resolvedInactive,
        labelStyle: AppTextStyles.s14w600(color: resolvedActive),
        unselectedLabelStyle: AppTextStyles.s14w400(color: resolvedInactive),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: resolvedActive, width: 2.5.h),
          borderRadius: BorderRadius.circular(2.r),
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(
          resolvedActive.withValues(alpha: 0.06),
        ),
        tabs: [for (final label in tabs) Tab(height: 40.h, text: label)],
      ),
    );
  }
}
