import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

/// Màn hình thông báo từ chối truy cập khi tài khoản không phải Admin.
class MemberAccessDeniedView extends StatelessWidget {
  final VoidCallback onBack;

  const MemberAccessDeniedView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_person_outlined,
                  size: 52.r,
                  color: AppColors.error,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Không có quyền truy cập',
                  style: AppTextStyles.s16w600(color: AppColors.textPrimary),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Tính năng quản trị thành viên chỉ dành cho tài khoản Admin.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s14w400(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: onBack,
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

