import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AppButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;
  final IconData? icon;
  final Widget? iconWidget;
  final EdgeInsetsGeometry? padding;
  final BorderSide? side;

  const AppButton({
    super.key,
    this.text,
    this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
    this.textStyle,
    this.icon,
    this.iconWidget,
    this.padding,
    this.side,
  });

  String get _buttonText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w),
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          elevation: elevation ?? 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.r, color: textColor ?? Colors.white),
                    SizedBox(width: 8.w),
                  ] else if (iconWidget != null) ...[
                    iconWidget!,
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Text(
                      _buttonText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          textStyle ??
                          AppTextStyles.s14w600(color: textColor ?? Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
