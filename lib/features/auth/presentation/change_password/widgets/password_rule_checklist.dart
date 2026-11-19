import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/text_style.dart';

/// Danh sách 4 quy tắc mật khẩu bố trí 2 cột, tự động đổi tick xanh khi đạt.
class PasswordRuleChecklist extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUpperAndLower;
  final bool hasDigit;
  final bool differsFromOld;

  const PasswordRuleChecklist({
    super.key,
    required this.hasMinLength,
    required this.hasUpperAndLower,
    required this.hasDigit,
    required this.differsFromOld,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PasswordRuleItem(
                label: 'Tối thiểu 8 ký tự',
                isPassed: hasMinLength,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: PasswordRuleItem(
                label: 'Chữ hoa và chữ thường',
                isPassed: hasUpperAndLower,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: PasswordRuleItem(
                label: 'Có ít nhất 1 chữ số',
                isPassed: hasDigit,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: PasswordRuleItem(
                label: 'Khác mật khẩu hiện tại',
                isPassed: differsFromOld,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Một dòng quy tắc đơn lẻ có thể tái sử dụng ở các màn hình nhập mật khẩu khác.
class PasswordRuleItem extends StatelessWidget {
  final String label;
  final bool isPassed;

  const PasswordRuleItem({
    super.key,
    required this.label,
    required this.isPassed,
  });

  static const _passedColor = Color(0xFF15803D);
  static const _pendingColor = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final color = isPassed ? _passedColor : _pendingColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isPassed
              ? Icons.check_circle_outline_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 16.r,
          color: color,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.s12w500(color: color),
          ),
        ),
      ],
    );
  }
}
