import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

/// TextField dùng chung cho toàn bộ ứng dụng, tuân thủ AppTheme & Clean Design
class AppTextField extends StatefulWidget {
  final String? label;
  final bool isRequired;
  final String? hintText;
  final String? hint; // Hỗ trợ tương thích ngược
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final bool showClearButton;
  final Widget? prefixIcon;
  final String? prefixSvgPath;
  final Widget? suffixIcon;
  final String? suffixText;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final bool autoFocus;
  final FocusNode? focusNode;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextStyle? hintStyle;

  const AppTextField({
    super.key,
    this.label,
    this.isRequired = false,
    this.hintText,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.onSaved,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.isPassword = false,
    this.showClearButton = false,
    this.prefixIcon,
    this.prefixSvgPath,
    this.suffixIcon,
    this.suffixText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.autoFocus = false,
    this.focusNode,
    this.borderRadius,
    this.contentPadding,
    this.margin,
    this.fillColor,
    this.textAlign = TextAlign.start,
    this.style,
    this.hintStyle,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  TextEditingController? _internalController;
  bool _hasText = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  String? get _effectiveHint => widget.hintText ?? widget.hint;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue);
    }

    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController(text: widget.initialValue);
      }
      _effectiveController.addListener(_handleControllerChange);
      _hasText = _effectiveController.text.isNotEmpty;
    }
  }

  void _handleControllerChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _hasText) {
      if (mounted) {
        setState(() {
          _hasText = hasText;
        });
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _clearText() {
    _effectiveController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 12.r;
    final effectiveFillColor = widget.fillColor ?? Colors.white;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
    );

    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            RichText(
              text: TextSpan(
                text: widget.label!,
                style: AppTextStyles.labelLarge(color: AppColors.textPrimary),
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
            controller: _effectiveController,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autoFocus,
            focusNode: widget.focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            textAlign: widget.textAlign,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            onSaved: widget.onSaved,
            style:
                widget.style ??
                AppTextStyles.bodyMedium(color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: _effectiveHint,
              hintStyle:
                  widget.hintStyle ??
                  AppTextStyles.bodyMedium(color: const Color(0xFF94A3B8)),
              errorText: widget.errorText,
              errorMaxLines: 2,
              errorStyle: AppTextStyles.labelSmall(color: Colors.redAccent),
              prefixIcon: _buildPrefixIcon(),
              suffixIcon: _buildSuffixIcon(),
              suffixIconConstraints: BoxConstraints(
                minWidth: 36.w,
                minHeight: 0,
              ),
              suffixText: widget.suffixText,
              suffixStyle: AppTextStyles.bodyMedium(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: effectiveFillColor,
              contentPadding:
                  widget.contentPadding ??
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: baseBorder,
              enabledBorder: baseBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder.copyWith(
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              disabledBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ],
      ),
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
    return widget.prefixIcon;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: UnconstrainedBox(
          child: SvgPicture.asset(
            _obscureText
                ? 'assets/icons/sign_in/ic_show.svg'
                : 'assets/icons/sign_in/ic_hide.svg',
            width: 20.r,
            height: 20.r,
          ),
        ),
        tooltip: _obscureText ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        splashRadius: 18.r,
      );
    }

    if (widget.showClearButton && _hasText) {
      return IconButton(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.close_rounded,
          size: 18.r,
          color: const Color(0xFF94A3B8),
        ),
        tooltip: 'Xóa nội dung',
        onPressed: _clearText,
        splashRadius: 16.r,
      );
    }

    return widget.suffixIcon;
  }
}
