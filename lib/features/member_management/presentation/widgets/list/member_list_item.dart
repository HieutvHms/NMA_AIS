import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/member_entity.dart';

enum MemberItemAction { viewDetail, edit, toggleLock, delete }

class MemberListItem extends StatelessWidget {
  final MemberEntity member;
  final VoidCallback onTap;
  final ValueChanged<MemberItemAction> onActionSelected;

  const MemberListItem({
    super.key,
    required this.member,
    required this.onTap,
    required this.onActionSelected,
  });

  static const _avatarPalettes = <_AvatarPalette>[
    _AvatarPalette(bg: Color(0xFFDFF4EC), fg: Color(0xFF0F6B4E)), // Mint
    _AvatarPalette(bg: Color(0xFFF6E7DF), fg: Color(0xFF8C4A27)), // Peach
    _AvatarPalette(bg: Color(0xFFF9E2E7), fg: Color(0xFF9F2A45)), // Rose
    _AvatarPalette(bg: Color(0xFFE7E8FA), fg: Color(0xFF4348A8)), // Lavender
    _AvatarPalette(bg: Color(0xFFE6F2DF), fg: Color(0xFF3E6E24)), // Sage
  ];

  _AvatarPalette get _palette {
    final index = member.userId.abs() % _avatarPalettes.length;
    return _avatarPalettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final radius = BorderRadius.circular(16.r);
    final subtitleText = member.email.trim().isNotEmpty
        ? member.email.trim()
        : '@${member.username}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderDark, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3B7A).withValues(alpha: 0.12),
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                _MemberAvatar(
                  initials: member.initials,
                  backgroundColor: palette.bg,
                  foregroundColor: palette.fg,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.s14w600(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s13w500(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<MemberItemAction>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSecondary,
                    size: 24.r,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  color: Colors.white,
                  onSelected: onActionSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: MemberItemAction.viewDetail,
                      child: _buildMenuRow(
                        'assets/icons/member/ic_view.svg',
                        'Xem chi tiết',
                      ),
                    ),
                    PopupMenuItem(
                      value: MemberItemAction.edit,
                      child: _buildMenuRow(
                        'assets/icons/member/ic_edit.svg',
                        'Chỉnh sửa thông tin',
                      ),
                    ),
                    PopupMenuItem(
                      value: MemberItemAction.toggleLock,
                      child: _buildMenuRow(
                        'assets/icons/member/ic_pass.svg',
                        'Khoá tài khoản',
                      ),
                    ),
                    PopupMenuItem(
                      value: MemberItemAction.delete,
                      child: _buildMenuRow(
                        'assets/icons/member/ic_delete.svg',
                        'Xoá thành viên',
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(String svgPath, String label, {Color? color}) {
    final textColor = color ?? AppColors.textPrimary;
    return Row(
      children: [
        SvgPicture.asset(
          svgPath,
          width: 18.r,
          height: 18.r,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        ),
        SizedBox(width: 10.w),
        Text(label, style: AppTextStyles.s14w500(color: textColor)),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final Color foregroundColor;

  const _MemberAvatar({
    required this.initials,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.r,
      height: 44.r,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.s15w600(color: foregroundColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPalette {
  final Color bg;
  final Color fg;

  const _AvatarPalette({required this.bg, required this.fg});
}
