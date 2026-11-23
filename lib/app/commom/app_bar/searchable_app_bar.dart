import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../theme/text_style.dart';
import '../../../../../app/theme/app_colors.dart';

import '../inputs/app_search_bar.dart';

/// AppBar chuẩn chung có hỗ trợ hiệu ứng chuyển cảnh mượt mà giữa chế độ thường và tìm kiếm
class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  // --- Tiêu đề & Căn chỉnh ---
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleStyle;
  final bool centerTitle;

  // --- Nút điều hướng (Leading) ---
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;

  // --- Các nút thao tác phụ (Actions) ---
  final List<Widget>? actions;
  final bool showSearchIcon;
  final bool searchBeforeActions;
  final Widget? searchIcon;
  final String searchSvgPath;
  final Widget? closeSearchIcon;

  // --- Tìm kiếm (Search) ---
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? searchHintText;
  final TextStyle? searchHintStyle;
  final ValueChanged<String>?
  onSearch; // Hỗ trợ tương thích ngược (onSearchChanged)
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchOpened;
  final VoidCallback? onSearchClosed;
  final VoidCallback? onSearchCleared;
  final Color? searchBackgroundColor;
  final BoxBorder? searchBorder;
  final double? searchBorderRadius;
  final double? searchHeight;

  // --- Hiệu ứng Animation ---
  final Duration animationDuration;
  final Curve animationCurve;

  // --- Giao diện & Màu sắc AppBar ---
  final Color? backgroundColor;
  final Color textColor;
  final double toolbarHeight;
  final double? elevation;
  final Color? surfaceTintColor;
  final SystemUiOverlayStyle? systemOverlayStyle;

  // --- Đường viền & Bottom ---
  final PreferredSizeWidget? bottom;
  final bool showBottomBorder;
  final Color? bottomBorderColor;
  final double bottomBorderHeight;

  const SearchableAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.titleStyle,
    this.centerTitle = true,
    this.leading,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.showSearchIcon = true,
    this.searchBeforeActions = true,
    this.searchIcon,
    this.searchSvgPath = 'assets/icons/device/ic_search.svg',
    this.closeSearchIcon,
    this.searchController,
    this.searchFocusNode,
    this.searchHintText,
    this.searchHintStyle,
    this.onSearch,
    this.onSearchSubmitted,
    this.onSearchOpened,
    this.onSearchClosed,
    this.onSearchCleared,
    this.searchBackgroundColor,
    this.searchBorder,
    this.searchBorderRadius,
    this.searchHeight,
    this.animationDuration = const Duration(milliseconds: 260),
    this.animationCurve = Curves.easeInOutCubic,
    this.backgroundColor,
    this.textColor = const Color(0xFF1E293B),
    this.toolbarHeight = kToolbarHeight,
    this.elevation = 0,
    this.surfaceTintColor = Colors.transparent,
    this.systemOverlayStyle,
    this.bottom,
    this.showBottomBorder = false,
    this.bottomBorderColor,
    this.bottomBorderHeight = 1.0,
  });

  @override
  Size get preferredSize {
    double extraHeight = 0;
    if (bottom != null) {
      extraHeight += bottom!.preferredSize.height;
    } else if (showBottomBorder) {
      extraHeight += bottomBorderHeight;
    }
    return Size.fromHeight(toolbarHeight + extraHeight);
  }

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();
}

class _SearchableAppBarState extends State<SearchableAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  late TextEditingController _searchController;
  late FocusNode _focusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    _initController();
    _initFocusNode();
  }

  void _initController() {
    if (widget.searchController != null) {
      _searchController = widget.searchController!;
      _isInternalController = false;
    } else {
      _searchController = TextEditingController();
      _isInternalController = true;
    }
  }

  void _initFocusNode() {
    if (widget.searchFocusNode != null) {
      _focusNode = widget.searchFocusNode!;
      _isInternalFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(covariant SearchableAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }

    if (widget.searchController != oldWidget.searchController) {
      if (_isInternalController) {
        _searchController.dispose();
      }
      _initController();
    }

    if (widget.searchFocusNode != oldWidget.searchFocusNode) {
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      _initFocusNode();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isInternalController) {
      _searchController.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    widget.onSearchOpened?.call();
    _animationController.forward().then((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _closeSearch() {
    final hadText = _searchController.text.isNotEmpty;
    _searchController.clear();
    if (hadText) {
      widget.onSearch?.call('');
      widget.onSearchCleared?.call();
    }
    widget.onSearchClosed?.call();
    _focusNode.unfocus();

    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _handleBack() {
    if (_isSearching) {
      _closeSearch();
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.pop();
        }
      }
    }
  }

  Widget _buildLeading() {
    if (widget.leading != null) {
      return widget.leading!;
    }

    if (widget.showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: widget.textColor,
          size: 20.sp,
        ),
        onPressed: _handleBack,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSearchIconButton() {
    return IconButton(
      icon:
          widget.searchIcon ??
          SvgPicture.asset(
            widget.searchSvgPath,
            width: 22.r,
            height: 22.r,
            colorFilter: ColorFilter.mode(widget.textColor, BlendMode.srcIn),
          ),
      onPressed: _openSearch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLeading = widget.leading != null || widget.showBackButton;
    final leadingWidth = hasLeading ? 48.w : 16.w;

    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearching) {
          _closeSearch();
        }
      },
      child: AppBar(
        backgroundColor: widget.backgroundColor ?? Colors.transparent,
        surfaceTintColor: widget.surfaceTintColor,
        elevation: widget.elevation,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: widget.systemOverlayStyle,
        titleSpacing: 0,
        bottom:
            widget.bottom ??
            (widget.showBottomBorder
                ? PreferredSize(
                    preferredSize: Size.fromHeight(widget.bottomBorderHeight),
                    child: Container(
                      color:
                          widget.bottomBorderColor ?? AppColors.textSecondary,
                      height: widget.bottomBorderHeight,
                    ),
                  )
                : null),
        title: SizedBox(
          height: widget.toolbarHeight,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final t = _animation.value;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Layer thường: Leading + Tiêu đề + Actions + Search Icon
                  Positioned.fill(
                    child: Opacity(
                      opacity: (1.0 - t).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(-30 * t, 0),
                        child: IgnorePointer(
                          ignoring: _isSearching,
                          child: Row(
                            children: [
                              SizedBox(
                                width: leadingWidth,
                                child: _buildLeading(),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: widget.centerTitle
                                      ? Alignment.center
                                      : Alignment.centerLeft,
                                  child:
                                      widget.titleWidget ??
                                      Text(
                                        widget.title ?? '',
                                        style:
                                            widget.titleStyle ??
                                            AppTextStyles.s16w600(
                                              color: widget.textColor,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ),
                              if (widget.searchBeforeActions &&
                                  widget.showSearchIcon)
                                _buildSearchIconButton(),
                              if (widget.actions != null) ...widget.actions!,
                              if (!widget.searchBeforeActions &&
                                  widget.showSearchIcon)
                                _buildSearchIconButton(),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Layer tìm kiếm: Nút Back + Ô search mở rộng + Nút đóng
                  Positioned.fill(
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(30 * (1.0 - t), 0),
                        child: IgnorePointer(
                          ignoring: !_isSearching,
                          child: Row(
                            children: [
                              // Nút quay lại/đóng search ở bên trái
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: widget.textColor,
                                  size: 20.sp,
                                ),
                                onPressed: _closeSearch,
                              ),
                              Expanded(
                                child: AppSearchBar(
                                  controller: _searchController,
                                  focusNode: _focusNode,
                                  hintText:
                                      widget.searchHintText ?? 'Tìm kiếm...',
                                  hintStyle:
                                      widget.searchHintStyle ??
                                      AppTextStyles.s13w500(
                                        color: AppColors.textSecondary,
                                      ),
                                  height: widget.searchHeight ?? 38.h,
                                  margin: EdgeInsets.zero,
                                  borderRadius:
                                      widget.searchBorderRadius ?? 12.r,
                                  backgroundColor:
                                      widget.searchBackgroundColor ??
                                      const Color(0xFFF1F5F9),
                                  border: widget.searchBorder,
                                  onChanged: (query) =>
                                      widget.onSearch?.call(query),
                                  onSubmitted: widget.onSearchSubmitted,
                                  onClear: () {
                                    widget.onSearch?.call('');
                                    widget.onSearchCleared?.call();
                                  },
                                ),
                              ),
                              // Nút đóng tìm kiếm bên phải
                              IconButton(
                                icon:
                                    widget.closeSearchIcon ??
                                    Icon(
                                      Icons.close_rounded,
                                      color: widget.textColor,
                                      size: 24.sp,
                                    ),
                                onPressed: _closeSearch,
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
