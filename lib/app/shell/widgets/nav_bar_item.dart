import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class NavBarItemData {
  final String path;
  final String label;
  final IconData? icon;
  final IconData? activeIcon;
  final String? svgPath;
  final String? activeSvgPath;

  const NavBarItemData({
    required this.path,
    required this.label,
    this.icon,
    this.activeIcon,
    this.svgPath,
    this.activeSvgPath,
  });
}

class NavBarItem extends StatelessWidget {
  final NavBarItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    final svgAsset = isSelected
        ? (item.activeSvgPath ?? item.svgPath)
        : item.svgPath;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: svgAsset != null
                    ? SvgPicture.asset(
                        svgAsset,
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      )
                    : Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: color,
                        size: 22.r,
                      ),
              ),
              SizedBox(height: 2.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isSelected
                    ? AppTextStyles.s13w600(color: color)
                    : AppTextStyles.s13w500(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
