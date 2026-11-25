import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/commom/skeleton/app_skeleton.dart';
import '../../../../../app/commom/tables/ais_device_table_view.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../domain/entities/device_entity.dart';
import '../../device_list/cubit/device_list_cubit.dart';
import '../../device_list/cubit/device_list_state.dart';

class DeviceTableScreen extends StatefulWidget {
  const DeviceTableScreen({super.key});

  @override
  State<DeviceTableScreen> createState() => _DeviceTableScreenState();
}

class _DeviceTableScreenState extends State<DeviceTableScreen> {
  final _searchController = TextEditingController();
  String _localQuery = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DeviceListCubit>();
    if (cubit.state is DeviceListInitial) {
      cubit.loadDevices();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DeviceEntity> _filterDevices(List<DeviceEntity> devices) {
    final q = _localQuery.trim().toLowerCase();
    if (q.isEmpty) return devices;
    return devices.where((e) {
      return e.stationName.toLowerCase().contains(q) ||
          e.imei.toLowerCase().contains(q) ||
          e.mmsi.toLowerCase().contains(q) ||
          e.aisPort.toString().contains(q) ||
          e.simSerial.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Bảng thiết bị',
        backgroundColor: AppColors.background,
        textColor: AppColors.textAppbar,
        titleStyle: AppTextStyles.s16w600(color: AppColors.textAppbar),
        showBottomBorder: true,
        bottomBorderColor: const Color(0xFFE2E8F0),
        searchHintText: 'Tìm kiếm...',
        searchHintStyle: AppTextStyles.s13w400(color: AppColors.textMuted),
        searchController: _searchController,
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (val) => setState(() => _localQuery = val),
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/devices');
          }
        },
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.textAppbar,
              size: 22.r,
            ),
            tooltip: 'Làm mới',
            onPressed: () =>
                context.read<DeviceListCubit>().loadDevices(forceRefresh: true),
          ),
        ],
      ),
      body: BlocConsumer<DeviceListCubit, DeviceListState>(
        listener: (context, state) {
          if (state is DeviceListError) {
            SnackbarHelper.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is DeviceListLoading || state is DeviceListInitial) {
            return AppSkeletonListView(
              itemCount: 8,
              padding: EdgeInsets.all(12.r),
              itemBuilder: (_, _) => const AppSkeletonCardItem(
                subtitleLines: 1,
                showStatusBadge: true,
                showTrailing: false,
              ),
            );
          }
          if (state is DeviceListError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 52.r,
                      color: const Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Không thể tải dữ liệu',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s16w600(),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s13w400(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<DeviceListCubit>()
                          .loadDevices(forceRefresh: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: Icon(Icons.refresh_rounded, size: 18.r),
                      label: Text(
                        'Thử lại',
                        style: AppTextStyles.s14w500(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is DeviceListLoaded) {
            final filteredDevices = _filterDevices(state.devices);
            return AisDeviceTableView<DeviceEntity>(
              items: filteredDevices,
              emptyMessage: _localQuery.trim().isNotEmpty
                  ? 'Không tìm thấy thiết bị phù hợp'
                  : 'Không có dữ liệu thiết bị',
              rowBuilder: (item) => AisDeviceTableRow(
                stationName: item.stationName,
                imei: item.imei,
                mmsi: item.mmsi,
                simSerial: item.simSerial,
                aisPort: item.aisPort,
                statusLabel: item.status.label,
                statusColor: item.status == DeviceStatus.online
                    ? const Color(0xFF15803D)
                    : (item.status == DeviceStatus.offline
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B)),
                lastMessageTime: item.lastMessageTime,
                lastAisTime: item.lastAisTime,
                signalStrength: item.signalStrength,
                aisModuleType: item.aisModuleType,
              ),
              onSelect: (dev) {
                final routeId = dev.imei.isNotEmpty ? dev.imei : 'detail';
                context.push('/devices/$routeId', extra: dev);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
