import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final bool isRequired;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final bool showClearButton;
  final bool showSuccessIcon;
  final String? prefixSvgPath;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;
  final double? height;
  final double? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderWidth;
  final double? focusedBorderWidth;

  const AppTextField({
    super.key,
    this.label,
    this.isRequired = false,
    this.hintText,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isPassword = false,
    this.showClearButton = false,
    this.showSuccessIcon = false,
    this.prefixSvgPath,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.height,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderWidth,
    this.focusedBorderWidth,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
      _hasText = widget.controller?.text.isNotEmpty ?? false;
    }
  }

  void _handleControllerChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _clearText() {
    widget.controller?.clear();
    widget.onChanged?.call('');
  }

  OutlineInputBorder _buildBorder(Color color, double width, double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 12.r;
    final targetHeight = widget.height ?? 48.h;
    final verticalPadding = ((targetHeight - 20.h) / 2).clamp(8.h, 20.h);

    final baseBorder = _buildBorder(
      widget.borderColor ?? const Color(0xFFCBD5E1),
      widget.borderWidth ?? 1,
      radius,
    );
    final focusedBorder = _buildBorder(
      widget.focusedBorderColor ?? AppColors.primary,
      widget.focusedBorderWidth ?? 1,
      radius,
    );
    final errorBorder = _buildBorder(Colors.redAccent, 1.2, radius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text.rich(
            TextSpan(
              text: widget.label!,
              style: AppTextStyles.s12w500(color: AppColors.textPrimary),
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          obscureText: widget.isPassword ? _obscureText : false,
          enableSuggestions: !widget.isPassword,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textAlignVertical: (widget.maxLines > 1 && !widget.isPassword)
              ? TextAlignVertical.top
              : TextAlignVertical.center,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: AppTextStyles.s14w500().copyWith(
            decoration: TextDecoration.none,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.s14w500(color: const Color(0xFF94A3B8)),
            errorMaxLines: 2,
            errorStyle: AppTextStyles.s11w500(color: Colors.redAccent),
            prefixIcon: _buildPrefixIcon(),
            prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 0),
            suffixIcon: _buildSuffixIcon(),
            suffixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 0),
            filled: true,
            fillColor: widget.fillColor ?? Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: verticalPadding,
            ),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: _buildBorder(Colors.redAccent, 1.5, radius),
            disabledBorder: _buildBorder(const Color(0xFFE2E8F0), 1, radius),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixSvgPath != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: UnconstrainedBox(
          child: SvgPicture.asset(
            widget.prefixSvgPath!,
            width: 20.r,
            height: 20.r,
          ),
        ),
      );
    }
    if (widget.prefixIcon != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Icon(
          widget.prefixIcon,
          size: 19.r,
          color: AppColors.textSecondary,
        ),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    Widget? actionIcon;

    if (widget.isPassword) {
      actionIcon = IconButton(
        icon: UnconstrainedBox(
          child: SvgPicture.asset(
            _obscureText
                ? 'assets/icons/sign_in/ic_show.svg'
                : 'assets/icons/sign_in/ic_hide.svg',
            width: 20.r,
            height: 20.r,
          ),
        ),
        style: IconButton.styleFrom(
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
        onPressed: () => setState(() => _obscureText = !_obscureText),
        splashRadius: 18.r,
      );
    } else if (widget.showClearButton && _hasText) {
      actionIcon = IconButton(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.close_rounded,
          size: 18.r,
          color: const Color(0xFF94A3B8),
        ),
        onPressed: _clearText,
        splashRadius: 16.r,
      );
    }

    if (!widget.showSuccessIcon) return actionIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: actionIcon == null ? 12.w : 2.w),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 20.r,
            color: AppColors.online,
          ),
        ),
        if (actionIcon != null) actionIcon,
      ],
    );
  }
}
