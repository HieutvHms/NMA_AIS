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

  const AppFilterChipItem({
    required this.label,
    this.count,
    this.dotColor,
    this.activeColor = AppColors.textBlack,
    this.activeBackgroundColor,
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
        separatorBuilder: (_, _) => SizedBox(width: 4.w),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          final activeBgColor =
              item.activeBackgroundColor ?? AppColors.borderDark;
          final bgColor = isSelected ? activeBgColor : Colors.transparent;
          final textColor = isSelected
              ? item.activeColor
              : AppColors.textSecondary;
          final countColor = isSelected
              ? item.activeColor
              : AppColors.textSecondary;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!isSelected) onSelected(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: isSelected
                  ? ShapeDecoration(
                      color: bgColor,
                      shape: const StadiumBorder(),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.dotColor != null) ...[
                    Container(
                      width: 6.5.r,
                      height: 6.5.r,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.dotColor
                            : item.dotColor!.withValues(alpha: 0.75),
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
                    SizedBox(width: 5.w),
                    Text(
                      '${item.count}',
                      style: isSelected
                          ? AppTextStyles.s12w600(color: countColor)
                          : AppTextStyles.s12w500(color: countColor),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
