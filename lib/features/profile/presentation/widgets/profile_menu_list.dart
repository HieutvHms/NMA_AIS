import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/dia_logs/app_confirm_dialog.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/text_style.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/login/cubit/auth_cubit.dart';

class ProfileMenuList extends StatelessWidget {
  final UserEntity? user;

  const ProfileMenuList({super.key, this.user});

  void _showLogoutDialog(BuildContext context) {
    AppConfirmDialog.showLogout(
      context,
      onConfirm: () => context.read<AuthCubit>().logout(),
    );
  }

  void _showPermissionsDialog(BuildContext context) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Quyền hạn & Cổng kết nối',
                style: AppTextStyles.s16w600(color: const Color(0xFF0F2A4A)),
              ),
              SizedBox(height: 12.h),
              _buildPermissionRow(
                'Vai trò hệ thống',
                user!.isAdmin
                    ? 'Quản trị viên (Admin)'
                    : 'Người vận hành (User)',
                Icons.badge_outlined,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    String label,
    String value,
    IconData icon, {
    bool? isAllowed,
  }) {
    Color valueColor = const Color(0xFF0F2A4A);
    if (isAllowed != null) {
      valueColor = isAllowed
          ? const Color(0xFF15803D)
          : const Color(0xFFDC2626);
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: const Color(0xFF1565C0)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.s14w500(color: const Color(0xFF5B6B82)),
            ),
          ),
          Text(value, style: AppTextStyles.s14w500(color: valueColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileCard(
          children: [
            _ProfileMenuItem(
              svgPath: 'assets/icons/setting/ic_infomation.svg',
              label: 'Thông tin tài khoản',
              isFirst: true,
              onTap: () => _showPermissionsDialog(context),
            ),
            Divider(
              height: 1,
              thickness: 1,
              indent: 52.w,
              endIndent: 14.w,
              color: const Color(0xFFF1F5F9),
            ),
            _ProfileMenuItem(
              svgPath: 'assets/icons/setting/ic_pass.svg',
              label: 'Đổi mật khẩu',
              isLast: true,
              onTap: () => context.push(RouteNames.changePassword),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 1. Nhóm Tính năng quản lý thiết bị & giám sát
        _ProfileCard(
          children: [
            _ProfileMenuItem(
              svgPath: 'assets/icons/device/ic_device.svg',
              label: 'Quản lý trạm thu AIS',
              isFirst: true,
              isLast: !(user?.isAdmin ?? false),
              onTap: () => context.push(RouteNames.deviceManagement),
            ),
            if (user?.isAdmin ?? false) ...[
              Divider(
                height: 1,
                thickness: 1,
                indent: 52.w,
                endIndent: 14.w,
                color: const Color(0xFFF1F5F9),
              ),
              _ProfileMenuItem(
                svgPath: 'assets/icons/setting/ic_people.svg',
                label: 'Quản lý thành viên',
                isLast: true,
                onTap: () => context.push(RouteNames.memberManagement),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),

        // 3. Nhóm Thông tin ứng dụng
        _ProfileCard(
          children: [
            _ProfileMenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Phiên bản ứng dụng',
              value: '1.0.0',
              showChevron: false,
              isFirst: true,
              isLast: true,
              onTap: null,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // 4. Nhóm Đăng xuất
        _ProfileCard(
          children: [
            _ProfileMenuItem(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBgColor: const Color(0xFFFEE2E2),
              label: 'Đăng xuất',
              labelColor: const Color(0xFFDC2626),
              showChevron: false,
              isFirst: true,
              isLast: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: const Color.fromARGB(255, 198, 204, 211),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3B7A).withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String? svgPath;
  final IconData? icon;
  final String label;
  final String? value;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? labelColor;
  final bool showChevron;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    this.svgPath,
    this.icon,
    required this.label,
    this.value,
    this.iconColor,
    this.iconBgColor,
    this.labelColor,
    this.showChevron = true,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  }) : assert(
         svgPath != null || icon != null,
         'Phải cung cấp svgPath hoặc icon',
       );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF1565C0).withValues(alpha: 0.08),
        highlightColor: const Color(0xFF1565C0).withValues(alpha: 0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: iconBgColor ?? const Color(0xFFE8F1FC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: svgPath != null
                      ? SvgPicture.asset(
                          svgPath!,
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(
                            iconColor ?? const Color(0xFF1565C0),
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 20.r,
                          color: iconColor ?? const Color(0xFF1565C0),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.s14w500(
                    color: labelColor ?? const Color(0xFF0F2A4A),
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: AppTextStyles.s14w500(color: const Color(0xFF5B6B82)),
                ),
                SizedBox(width: 6.w),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 22.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
