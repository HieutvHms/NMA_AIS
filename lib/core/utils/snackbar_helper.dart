import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/text_style.dart';

class SnackbarHelper {
  static OverlayEntry? _currentEntry;

  static void showSuccess(
    BuildContext context, {
    String title = '',
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      isSuccess: true,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    String title = '',
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      isSuccess: false,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    String title = '',
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      isSuccess: null,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required bool? isSuccess,
    required String title,
    required String message,
    required Duration duration,
  }) {
    final overlayState =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context) ??
        (context is StatefulElement && context.state is NavigatorState
            ? (context.state as NavigatorState).overlay
            : null) ??
        Navigator.maybeOf(context)?.overlay;

    if (overlayState == null) return;

    // Gỡ snackbar cũ nếu đang hiển thị để tránh chồng nhiều lớp lên nhau
    _removeCurrentEntry();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _TopSnackBarWidget(
          isSuccess: isSuccess,
          title: title,
          message: message,
          duration: duration,
          onDismissed: () {
            if (_currentEntry == overlayEntry) {
              _currentEntry = null;
            }
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    overlayState.insert(overlayEntry);
  }

  static void _removeCurrentEntry() {
    final entry = _currentEntry;
    _currentEntry = null;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final bool? isSuccess;
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackBarWidget({
    required this.isSuccess,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color backgroundColor;

    if (widget.isSuccess == true) {
      icon = Icons.check_circle_rounded;
      backgroundColor = Colors.green.shade600;
    } else if (widget.isSuccess == false) {
      icon = Icons.error_rounded;
      backgroundColor = Colors.red.shade600;
    } else {
      icon = Icons.info_outline_rounded;
      backgroundColor = Colors.blue.shade600;
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 10.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) {
              _timer?.cancel();
              widget.onDismissed();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.title.isNotEmpty
                              ? widget.title
                              : widget.message,
                          style: widget.title.isNotEmpty
                              ? AppTextStyles.labelLarge(color: Colors.white)
                              : AppTextStyles.bodyMedium(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (widget.title.isNotEmpty && widget.message.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      widget.message,
                      style: AppTextStyles.bodyMedium(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
