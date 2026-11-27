import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../cubit/overview_cubit.dart';
import '../cubit/overview_state.dart';
import '../widgets/overview_alerts_section.dart';
import '../widgets/overview_kpi_card.dart';
import '../widgets/overview_live_minimap_card.dart';
import '../widgets/overview_skeleton.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OverviewCubit, OverviewState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<OverviewCubit>().loadOverview(isRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 6.h, 16.w, 24.h),
                children: [
                  _buildHeader(context, state),
                  SizedBox(height: 16.h),
                  if (state.isLoading)
                    const OverviewSkeleton()
                  else if (state.hasBothErrors)
                    _buildFullErrorCard(
                      context,
                      message:
                          state.devicesError ??
                          state.aisError ??
                          'Không thể tải dữ liệu tổng quan.',
                    )
                  else ...[
                    if (state.devicesError != null || state.aisError != null)
                      _buildPartialErrorBanner(
                        context,
                        message: state.devicesError ?? state.aisError!,
                      ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: OverviewKpiCard(
                              icon: Icons.router_rounded,
                              iconColor: AppColors.primary,
                              iconBgColor: AppColors.primaryLight,
                              count: state.totalDevices,
                              title: 'Thiết bị 4G',
                              hasError: state.devicesError != null,
                              metrics: [
                                OverviewKpiMetric(
                                  dotColor: AppColors.online,
                                  label: '${state.onlineDevices} trực tuyến',
                                ),
                                OverviewKpiMetric(
                                  dotColor: AppColors.offline,
                                  label: '${state.offlineDevices} ngoại tuyến',
                                ),
                              ],
                              onTap: () => context.go(RouteNames.devices),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OverviewKpiCard(
                              icon: Icons.radar_rounded,
                              iconColor: const Color(0xFF0F766E),
                              iconBgColor: const Color(0xFFCCFBF1),
                              count: state.totalAisTargets,
                              title: 'Tàu và Phao AIS',
                              hasError: state.aisError != null,
                              metrics: [
                                OverviewKpiMetric(
                                  dotColor: AppColors.primary,
                                  label: '${state.vesselCount} Tàu thuyền',
                                ),
                                OverviewKpiMetric(
                                  dotColor: const Color(0xFF0F766E),
                                  label:
                                      '${state.stationOrAtonCount} Phao / Đèn',
                                ),
                              ],
                              onTap: () => context.go(RouteNames.monitoring),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    OverviewLiveMinimapCard(
                      targets: state.aisTargets,
                      onOpenMapTap: () => context.go(RouteNames.monitoring),
                    ),
                    SizedBox(height: 20.h),
                    OverviewAlertsSection(
                      offlineDevices: state.offlineDeviceList,
                      abnormalAtons: state.abnormalAtonList,
                      onViewAllDevicesTap: () => context.go(RouteNames.devices),
                      onDeviceTap: (device) => context.push(
                        '${RouteNames.devices}/${device.imei}',
                        extra: device,
                      ),
                      onAtonTap: () => context.go(RouteNames.monitoring),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OverviewState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Trang chủ',
          textAlign: TextAlign.center,
          style: AppTextStyles.s17w600(color: AppColors.textAppbar),
        ),
        SizedBox(height: 10.h),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildPartialErrorBanner(
    BuildContext context, {
    required String message,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.offlineBg.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18.r, color: AppColors.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message.replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s12w500(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () =>
                context.read<OverviewCubit>().loadOverview(isRefresh: true),
            child: Text(
              'Thử lại',
              style: AppTextStyles.s12w600(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullErrorCard(BuildContext context, {required String message}) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.offlineBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: AppColors.error,
              size: 24.r,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.s13w500(color: AppColors.textSecondary),
          ),
          SizedBox(height: 14.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () =>
                context.read<OverviewCubit>().loadOverview(isRefresh: true),
            child: Text(
              'Thử lại',
              style: AppTextStyles.s13w600(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
