import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';

/// Hiệu ứng shimmer dùng chung cho mọi màn hình trong app (không cần thư viện ngoài).
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final slide = _controller.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (slide - 0.3).clamp(0.0, 1.0),
                slide.clamp(0.0, 1.0),
                (slide + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Khối placeholder cơ bản để ghép thành bất kỳ layout skeleton nào.
class AppSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  final Color color;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// Danh sách skeleton dùng chung (1 AnimationController cho cả danh sách).
class AppSkeletonListView extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double? separatorHeight;
  final IndexedWidgetBuilder? itemBuilder;

  const AppSkeletonListView({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.separatorHeight,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? EdgeInsets.all(12.r),
        itemCount: itemCount,
        separatorBuilder: (context, index) =>
            SizedBox(height: separatorHeight ?? 10.h),
        itemBuilder:
            itemBuilder ?? (context, index) => const AppSkeletonCardItem(),
      ),
    );
  }
}

/// Mẫu skeleton card phổ biến (icon trái + tiêu đề + badge + dòng phụ).
class AppSkeletonCardItem extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;
  final bool showStatusBadge;
  final int subtitleLines;

  const AppSkeletonCardItem({
    super.key,
    this.showLeading = true,
    this.showTrailing = true,
    this.showStatusBadge = true,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLeading) ...[
            AppSkeletonBox(width: 36.r, height: 36.r, borderRadius: 10),
            SizedBox(width: 14.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppSkeletonBox(height: 15.h, borderRadius: 6),
                    ),
                    if (showStatusBadge) ...[
                      SizedBox(width: 12.w),
                      AppSkeletonBox(
                        width: 68.w,
                        height: 14.h,
                        borderRadius: 12,
                      ),
                    ],
                  ],
                ),
                for (int i = 0; i < subtitleLines; i++) ...[
                  SizedBox(height: 8.h),
                  AppSkeletonBox(
                    width: i == subtitleLines - 1 ? 140.w : double.infinity,
                    height: 12.h,
                    borderRadius: 6,
                  ),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            SizedBox(width: 10.w),
            AppSkeletonBox(width: 14.r, height: 14.r, borderRadius: 4),
          ],
        ],
      ),
    );
  }
}

