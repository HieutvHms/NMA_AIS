import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

class MemberTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onAddMember;

  const MemberTopBar({
    super.key,
    required this.onBack,
    required this.onAddMember,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
      leading: IconButton(
        onPressed: onBack,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.r,
          color: AppColors.textAppbar,
        ),
      ),
      title: Text(
        'Thành viên',
        style: AppTextStyles.s16w600(color: AppColors.textAppbar),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Center(
            child: Material(
              color: const Color(0xFFDCEAFB),
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: onAddMember,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFC6DCF7),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/member/ic_add_member.svg',
                    width: 24.r,
                    height: 24.r,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textAppbar,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
