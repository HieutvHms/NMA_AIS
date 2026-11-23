import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AppFilterChipItem {
  final String label;
  final int? count;
  final Color? dotColor;
  final Color activeColor;
  final Color? activeBackgroundColor;
  final Color? activeBorderColor;
  final Color? activeBadgeColor;

  const AppFilterChipItem({
    required this.label,
    this.count,
    this.dotColor,
    this.activeColor = AppColors.primary,
    this.activeBackgroundColor,
    this.activeBorderColor,
    this.activeBadgeColor,
  });
}

class AppFilterChipBar extends StatelessWidget {
  final List<AppFilterChipItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry? padding;

  const AppFilterChipBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          final bgColor = isSelected
              ? (item.activeBackgroundColor ??
                    item.activeColor.withValues(alpha: 0.12))
              : Colors.white;
          final borderColor = isSelected
              ? (item.activeBorderColor ??
                    item.activeColor.withValues(alpha: 0.45))
              : AppColors.borderDark;
          final textColor = isSelected
              ? item.activeColor
              : AppColors.textPrimary;
          final badgeBgColor = isSelected
              ? (item.activeBadgeColor ??
                    item.activeColor.withValues(alpha: 0.18))
              : const Color(0xFFF1F5F9);
          final badgeTextColor = isSelected
              ? item.activeColor
              : AppColors.textSecondary;

          return Material(
            color: bgColor,
            shape: StadiumBorder(
              side: BorderSide(color: borderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(index),
              splashColor: item.activeColor.withValues(alpha: 0.1),
              highlightColor: item.activeColor.withValues(alpha: 0.05),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.dotColor != null) ...[
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: BoxDecoration(
                          color: item.dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      item.label,
                      style: isSelected
                          ? AppTextStyles.s13w600(color: textColor)
                          : AppTextStyles.s13w500(color: textColor),
                    ),
                    if (item.count != null) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${item.count}',
                          style: AppTextStyles.s11w600(color: badgeTextColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
