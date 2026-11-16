import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/app_bottom_nav_bar.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool? showBottomNavBar;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
    this.showBottomNavBar,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isNavVisible =
        showBottomNavBar ?? AppBottomNavBar.shouldShowForLocation(currentPath);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isNavVisible
          ? AppBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              isVisible: isNavVisible,
              onTap: _onTap,
            )
          : null,
    );
  }
}
