import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../cubit/device_list_cubit.dart';
import '../cubit/device_list_state.dart';
import '../../../domain/entities/device_entity.dart';
import '../widgets/device_list_item.dart';

/// Màn hình danh sách thiết bị AIS tuân thủ Mockup 3 và Clean Architecture
class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final _searchController = TextEditingController();
  DeviceStatus? _currentStatusFilter;

  @override
  void initState() {
    super.initState();
    context.read<DeviceListCubit>().loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(DeviceStatus? status) {
    setState(() {
      _currentStatusFilter = status;
    });
    context.read<DeviceListCubit>().loadDevices(
      query: _searchController.text,
      statusFilter: status,
      clearFilter: status == null,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lọc trạng thái thiết bị',
                  style: AppTextStyles.titleMediumBlack(),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  title: Text(
                    'Tất cả trạng thái',
                    style: AppTextStyles.bodyMedium(),
                  ),
                  leading: const Icon(Icons.all_inclusive_rounded),
                  trailing: _currentStatusFilter == null
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _applyFilter(null);
                  },
                ),
                ListTile(
                  title: Text(
                    'Online',
                    style: AppTextStyles.bodyMedium(
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF16A34A),
                  ),
                  trailing: _currentStatusFilter == DeviceStatus.online
                      ? const Icon(Icons.check, color: Color(0xFF16A34A))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _applyFilter(DeviceStatus.online);
                  },
                ),
                ListTile(
                  title: Text(
                    'Ngoại tuyến (Offline)',
                    style: AppTextStyles.bodyMedium(
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  leading: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFDC2626),
                  ),
                  trailing: _currentStatusFilter == DeviceStatus.offline
                      ? const Icon(Icons.check, color: Color(0xFFDC2626))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _applyFilter(DeviceStatus.offline);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Thiết bị',
        titleStyle: AppTextStyles.titleMediumAppBar(
          color: const Color(0xFF1565C0),
        ),
        backgroundColor: AppColors.background,
        textColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/device/ic_grid.svg',
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              Color(0xFF1565C0),
              BlendMode.srcIn,
            ),
          ),
          tooltip: 'Xem dạng bảng dữ liệu',
          onPressed: () => context.push('/devices/table'),
        ),
        showBackButton: false,
        showBottomBorder: true,
        bottomBorderColor: const Color(0xFFE2E8F0),
        searchController: _searchController,
        searchHintText: 'Tìm kiếm...',
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (value) => context.read<DeviceListCubit>().loadDevices(
          query: value,
          statusFilter: _currentStatusFilter,
        ),
        onFilter: _showFilterSheet,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _currentStatusFilter != null
                  ? const Color(0xFF1565C0)
                  : const Color(0xFF475569),
              size: 22.r,
            ),
            tooltip: 'Bộ lọc trạng thái',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentStatusFilter != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lọc: ${_currentStatusFilter!.label}',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        InkWell(
                          onTap: () => _applyFilter(null),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<DeviceListCubit, DeviceListState>(
              builder: (context, state) {
                if (state is DeviceListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DeviceListError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium(color: Colors.red),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () =>
                              context.read<DeviceListCubit>().loadDevices(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is DeviceListLoaded) {
                  if (state.devices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.devices_other_rounded,
                            size: 48.r,
                            color: const Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Không tìm thấy thiết bị nào.',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_currentStatusFilter != null ||
                              _searchController.text.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter(null);
                              },
                              child: const Text('Xóa bộ lọc'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<DeviceListCubit>().loadDevices(
                          query: _searchController.text,
                          statusFilter: _currentStatusFilter,
                        ),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                      itemCount: state.devices.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final device = state.devices[index];
                        return DeviceListItem(
                          device: device,
                          onTap: () => context.push(
                            '/devices/${device.imei}',
                            extra: device,
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
