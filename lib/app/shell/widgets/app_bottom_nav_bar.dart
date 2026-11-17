import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'nav_bar_item.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isVisible;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  static const List<NavBarItemData> tabs = [
    NavBarItemData(
      path: '/overview',
      label: 'Trang chủ',
      svgPath: 'assets/icons/navbar/ic_home.svg',
    ),
    NavBarItemData(
      path: '/devices',
      label: 'Thiết bị',
      svgPath: 'assets/icons/navbar/ic_device.svg',
    ),
    NavBarItemData(
      path: '/monitoring',
      label: 'Giám sát',
      svgPath: 'assets/icons/navbar/ic_map.svg',
    ),
    NavBarItemData(
      path: '/profile',
      label: 'Tài khoản',
      svgPath: 'assets/icons/navbar/ic_user.svg',
    ),
  ];

  /// Kiểm tra đường dẫn hiện tại có thuộc danh sách các tab gốc hay không.
  /// Nếu mở màn hình con (chi tiết, cấu hình,...) không trùng path của tab thì ẩn Navbar.
  static bool shouldShowForLocation(String location) {
    final normalized = location.endsWith('/') && location.length > 1
        ? location.substring(0, location.length - 1)
        : location;
    return tabs.any((tab) => tab.path == normalized);
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    // Trên iPhone có viền đáy an toàn (Home indicator) bottomInset ~ 34px
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final hasBottomInset = bottomInset > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3B7A).withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.w,
            right: 8.w,
            top: 5.h,
            // Nếu đã có Safe Area (iPhone) thì chỉ cần padding tối thiểu 2.h,
            // tránh đội thêm khoảng trắng lớn dưới chân trang
            bottom: hasBottomInset ? 2.h : 6.h,
          ),
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => NavBarItem(
                item: tabs[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
