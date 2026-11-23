import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../app/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/ais_logo.png',
            width: 56.r,
            height: 56.r,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NMA AIS',
              style: AppTextStyles.titleLarge(
                color: AppColors.textAppbar,
              ).copyWith(height: 1.15),
            ),
            SizedBox(height: 2.h),
            Text(
              'Configure · Monitor · Track',
              style: AppTextStyles.s13w500(color: AppColors.textAppbar),
            ),
          ],
        ),
      ],
    );
  }
}
