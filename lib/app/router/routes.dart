import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/ais_config/cubit/ais_config_cubit.dart';
import '../../features/ais_config/presentation/screens/ais_config_screen.dart';
import '../../features/ais_config/presentation/screens/buoy_config_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/device/presentation/device_config/cubit/device_config_cubit.dart';
import '../../features/device/presentation/device_list/cubit/device_list_cubit.dart';
import '../../features/device/domain/entities/device_entity.dart';
import '../../features/device/presentation/device_config/screens/device_config_screen.dart';
import '../../features/device/presentation/device_detail/screens/device_detail_screen.dart';
import '../../features/device/presentation/device_list/screens/device_list_screen.dart';
import '../../features/device/presentation/device_table/screens/device_table_screen.dart';
import '../../features/monitoring/cubit/monitoring_cubit.dart';
import '../../features/monitoring/cubit/route_cubit.dart';
import '../../features/monitoring/data/models/vessel_model.dart';
import '../../features/monitoring/presentation/screens/monitor_screen.dart';
import '../../features/monitoring/presentation/screens/route_screen.dart';
import '../../features/monitoring/presentation/screens/vessel_detail_screen.dart';
import '../../features/overview/presentation/screens/overview_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/device_management/presentation/cubit/device_management_cubit.dart';
import '../../features/device_management/presentation/screens/device_management_screen.dart';
import '../../features/device_management/presentation/device_table/screens/managed_device_table_screen.dart';
import '../di/injection_container.dart';
import '../shell/main_shell_screen.dart';
import '../shell/widgets/app_bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/overview',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state is Authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && isLoggingIn) {
        return '/overview';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final showNav = AppBottomNavBar.shouldShowForLocation(state.uri.path);
          return MainShellScreen(
            navigationShell: navigationShell,
            showBottomNavBar: showNav,
          );
        },
        branches: [
          // Tab 0: Tổng quan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          // Tab 1: Thiết bị
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/devices',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<DeviceListCubit>(),
                  child: const DeviceListScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'table',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => sl<DeviceListCubit>(),
                      child: const DeviceTableScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final device = state.extra as DeviceEntity;
                      return DeviceDetailScreen(device: device);
                    },
                    routes: [
                      GoRoute(
                        path: 'config',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final device = state.extra as DeviceEntity;
                          return BlocProvider(
                            create: (_) => sl<DeviceConfigCubit>(),
                            child: DeviceConfigScreen(device: device),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'ais-config',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final deviceId = state.pathParameters['id']!;
                          return BlocProvider(
                            create: (_) => sl<AisConfigCubit>(),
                            child: AisConfigScreen(deviceId: deviceId),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'buoy-config',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final deviceId = state.pathParameters['id']!;
                          return BuoyConfigScreen(deviceId: deviceId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: Giám sát
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/monitoring',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<MonitoringCubit>(),
                  child: const MonitorScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'detail/:mmsi',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final vessel = state.extra as VesselModel;
                      return VesselDetailScreen(vessel: vessel);
                    },
                  ),
                  GoRoute(
                    path: 'route/:mmsi',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final mmsi = state.pathParameters['mmsi']!;
                      return BlocProvider(
                        create: (_) => sl<RouteCubit>(),
                        child: RouteScreen(mmsi: mmsi),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 3: Cá nhân
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'device-management',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => sl<DeviceManagementCubit>()..loadDevices(),
                      child: const DeviceManagementScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'table',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => BlocProvider(
                          create: (_) =>
                              sl<DeviceManagementCubit>()..loadDevices(),
                          child: const ManagedDeviceTableScreen(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
