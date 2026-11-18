import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/text_style.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key, required this.user});

  final UserEntity user;

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed
        .split(RegExp(r'[\s_.-]+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar + Nút camera nhỏ
        Stack(
          children: [
            Container(
              width: 76.r,
              height: 76.r,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E3F8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D3B7A).withValues(alpha: 0.12),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(user.username),
                  style: AppTextStyles.titleLarge(
                    color: const Color(0xFF1565C0),
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 24.sp),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 13.r,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Tên tài khoản
        Text(
          user.username.isNotEmpty ? user.username : 'Người dùng',
          style: AppTextStyles.s16w600(color: const Color(0xFF0F2A4A)),
        ),
        SizedBox(height: 6.h),

        // Huy hiệu vai trò (Admin / User)
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        //   decoration: BoxDecoration(
        //     color: user.isAdmin
        //         ? const Color(0xFFE8F1FC)
        //         : const Color(0xFFF1F5F9),
        //     borderRadius: BorderRadius.circular(20.r),
        //     border: Border.all(
        //       color: user.isAdmin
        //           ? const Color(0xFF93C5FD)
        //           : const Color(0xFFCBD5E1),
        //       width: 0.8,
        //     ),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(
        //         user.isAdmin
        //             ? Icons.admin_panel_settings_rounded
        //             : Icons.person_outline_rounded,
        //         size: 14.r,
        //         color: user.isAdmin
        //             ? const Color(0xFF1565C0)
        //             : const Color(0xFF5B6B82),
        //       ),
        //       SizedBox(width: 4.w),
        //       Text(
        //         user.isAdmin
        //             ? 'Quản trị viên (Admin)'
        //             : 'Người vận hành (User)',
        //         style: AppTextStyles.titleSmall(
        //           color: user.isAdmin
        //               ? const Color(0xFF1565C0)
        //               : const Color(0xFF5B6B82),
        //         ).copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
