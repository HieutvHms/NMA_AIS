import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/text_style.dart';
import '../cubit/change_password_state.dart';

/// Thanh độ mạnh mật khẩu gồm 4 đoạn kèm nhãn (Yếu / Trung bình / Khá / Mạnh).
class PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthBar({super.key, required this.strength});

  static const _inactiveColor = Color(0xFFE3E8F0);
  static const _weakColor = Color(0xFFC62828);
  static const _mediumColor = Color(0xFFD97706);
  static const _goodColor = Color(0xFF1C63C8);
  static const _strongColor = Color(0xFF15803D);

  Color get _activeColor {
    switch (strength) {
      case PasswordStrength.none:
        return _inactiveColor;
      case PasswordStrength.weak:
        return _weakColor;
      case PasswordStrength.medium:
        return _mediumColor;
      case PasswordStrength.good:
        return _goodColor;
      case PasswordStrength.strong:
        return _strongColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSegments = strength.level;
    final activeColor = _activeColor;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              final isFilled = index < activeSegments;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 6.w : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isFilled ? activeColor : _inactiveColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (strength != PasswordStrength.none) ...[
          SizedBox(width: 10.w),
          Text(
            strength.label,
            style: AppTextStyles.s12w600(color: activeColor),
          ),
        ],
      ],
    );
  }
}

