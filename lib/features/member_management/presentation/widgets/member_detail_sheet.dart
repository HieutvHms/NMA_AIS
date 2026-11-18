import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../domain/entities/member_entity.dart';

/// Bottom sheet hiển thị thông tin chi tiết của một thành viên.
class MemberDetailSheet extends StatelessWidget {
  final MemberEntity member;

  const MemberDetailSheet({super.key, required this.member});

  static Future<void> show(BuildContext context, MemberEntity member) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MemberDetailSheet(member: member),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Chưa có';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    member.initials,
                    style: AppTextStyles.s16w600(color: AppColors.primary),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        style: AppTextStyles.s16w600(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '@${member.username} · Thành viên',
                        style: AppTextStyles.s13w500(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.h),
            _DetailRow(
              label: 'User ID',
              value: member.userId.toString(),
              icon: Icons.badge_outlined,
            ),
            _DetailRow(
              label: 'Email',
              value: member.email.isNotEmpty ? member.email : 'Chưa cập nhật',
              icon: Icons.email_outlined,
            ),
            _DetailRow(
              label: 'Số điện thoại',
              value: member.phone.isNotEmpty ? member.phone : 'Chưa cập nhật',
              icon: Icons.phone_outlined,
            ),
            _DetailRow(
              label: 'Cổng UDP',
              value: member.udpPort.isNotEmpty
                  ? member.udpPort
                  : 'Chưa cấu hình',
              icon: Icons.settings_ethernet_rounded,
            ),
            _DetailRow(
              label: 'Ngày tạo',
              value: _formatDate(member.createdAt),
              icon: Icons.calendar_today_outlined,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Đóng',
                  style: AppTextStyles.s14w600(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            label,
            style: AppTextStyles.s13w500(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s13w600(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

