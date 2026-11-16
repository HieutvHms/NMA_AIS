import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/text_style.dart';

/// Thanh tìm kiếm dùng chung cho toàn bộ ứng dụng, thống nhất UI
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilter;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double? borderRadius;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Tìm kiếm theo tên, IMEI...',
    this.onChanged,
    this.onClear,
    this.onFilter,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.margin,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _controller.addListener(_onTextChanged);
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
              style: AppTextStyles.bodyMedium(),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyMedium(
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_rounded, size: 18.r),
              color: const Color(0xFF94A3B8),
              onPressed: _handleClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Xóa tìm kiếm',
            ),
          if (widget.onFilter != null) ...[
            SizedBox(width: 4.w),
            IconButton(
              icon: Icon(
                Icons.tune_rounded, // Icon bộ lọc theo Mockup 3
                color: const Color(0xFF475569),
                size: 20.r,
              ),
              tooltip: 'Bộ lọc trạng thái',
              onPressed: widget.onFilter,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              constraints: const BoxConstraints(),
            ),
          ] else ...[
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}
