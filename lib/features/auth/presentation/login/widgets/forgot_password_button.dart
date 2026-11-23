import 'package:flutter/material.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../../../app/theme/app_colors.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ForgotPasswordButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          onPressed ??
          () {
            SnackbarHelper.showInfo(
              context,
              title: 'Quên mật khẩu',
              message: 'Vui lòng liên hệ Quản trị viên để cấp lại mật khẩu.',
            );
          },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF16519F),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        'Quên mật khẩu?',
        style: AppTextStyles.s14w500(color: AppColors.textAppbar),
      ),
    );
  }
}
