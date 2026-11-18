import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/text_style.dart';

/// Thanh tìm kiếm dùng chung cho toàn bộ ứng dụng, thống nhất UI
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double? borderRadius;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const AppSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.hintText = 'Tìm kiếm theo tên, IMEI...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.margin,
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    _initController();
    _initFocusNode();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isInternalFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChanged);
      if (_isInternalController) {
        _controller.dispose();
      }
      _initController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      _initFocusNode();
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 12.r;
    final bgColor = widget.backgroundColor ?? const Color(0xFFF1F5F9);

    return Container(
      height: widget.height ?? 44.h,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: widget.border,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Icon(
              Icons.search_rounded,
              size: 20.r,
              color: const Color(0xFF94A3B8),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              style: widget.textStyle ?? AppTextStyles.s14w500(),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ?? AppTextStyles.s14w500(),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_rounded, size: 18.r),
              color: const Color(0xFF94A3B8),
              onPressed: _handleClear,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              constraints: const BoxConstraints(),
            )
          else
            SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
