import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

class DeviceActionsSection extends StatelessWidget {
  final VoidCallback onConfigTap;
  final VoidCallback onViewAisTap;
  final VoidCallback onHistoryTap;

  const DeviceActionsSection({
    super.key,
    required this.onConfigTap,
    required this.onViewAisTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chức năng', style: AppTextStyles.s15w600()),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.textBlack.withValues(alpha: 0.15),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              _DeviceActionTile(
                icon: Icons.settings_outlined,
                iconColor: AppColors.primary,
                title: 'Cấu hình thiết bị',
                onTap: onConfigTap,
              ),
              const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
              _DeviceActionTile(
                icon: Icons.show_chart_rounded,
                iconColor: AppColors.primary,
                title: 'Xem dữ liệu AIS',
                onTap: onViewAisTap,
              ),
              const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
              _DeviceActionTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Lịch sử cấu hình',
                onTap: onHistoryTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _DeviceActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24.r),
      title: Text(title, style: AppTextStyles.s14w500()),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
        size: 22.r,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }
}
