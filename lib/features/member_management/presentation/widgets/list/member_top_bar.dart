import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

/// Thanh tiêu đề màn hình Quản lý thành viên.
class MemberTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAddMember;

  const MemberTopBar({
    super.key,
    required this.onBack,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0.h, 12.w, 0.h),
      child: SizedBox(
        height: 42.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20.r,
                  color: AppColors.textAppbar,
                ),
              ),
            ),
            Text(
              'Thành viên',
              textAlign: TextAlign.center,
              style: AppTextStyles.s16w600(color: AppColors.textAppbar),
            ),
            Align(
              alignment: Alignment.centerRight,
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
          ],
        ),
      ),
    );
  }
}

