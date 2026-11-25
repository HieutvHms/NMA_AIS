import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/member_entity.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
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
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        style: AppTextStyles.s15w500(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 8.h),
            _DetailRow(
              label: 'Tên đăng nhập',
              value: member.username,
              svgPath: 'assets/icons/member/ic_name.svg',
            ),
            _DetailRow(
              label: 'Email',
              value: member.email.isNotEmpty ? member.email : 'Chưa cập nhật',
              svgPath: 'assets/icons/member/ic_email.svg',
            ),
            _DetailRow(
              label: 'Số điện thoại',
              value: member.phone.isNotEmpty ? member.phone : 'Chưa cập nhật',
              svgPath: 'assets/icons/member/ic_phone.svg',
            ),
            _DetailRow(
              label: 'Cổng UDP',
              value: member.udpPort.isNotEmpty
                  ? member.udpPort.join(', ')
                  : 'Chưa cấu hình',
              icon: Icons.settings_ethernet_rounded,
            ),
            _DetailRow(
              label: 'Ngày tạo',
              value: _formatDate(member.createdAt),
              icon: Icons.calendar_today_outlined,
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
  final String? svgPath;
  final IconData? icon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.svgPath,
    this.icon,
  }) : assert(svgPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath!,
              width: 18.r,
              height: 18.r,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(icon, size: 18.r, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            label,
            style: AppTextStyles.s13w500(color: AppColors.textSecondary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s13w500(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
