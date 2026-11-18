import 'package:flutter/material.dart';
import '../../../../app/theme/text_style.dart';
import 'ais_logo_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AisLogoIcon(size: 72.h),
        SizedBox(height: 14.h),
        Text(
          'NMA AIS',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge(
            color: const Color.fromARGB(255, 5, 81, 144),
          ),
        ),
        Text(
          'Quản lý và cấu hình thiết bị AIS',
          textAlign: TextAlign.center,
          style: AppTextStyles.s14w500(
            color: const Color.fromARGB(255, 5, 81, 144),
          ),
        ),
      ],
    );
  }
}
