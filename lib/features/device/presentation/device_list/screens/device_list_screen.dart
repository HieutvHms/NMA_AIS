import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/commom/skeleton/app_skeleton.dart';
import '../../../../../app/commom/tabs/app_filter_chip_bar.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../cubit/device_list_cubit.dart';
import '../cubit/device_list_state.dart';
import '../../../domain/entities/device_entity.dart';
import '../widgets/device_list_item.dart';
import '../widgets/device_sort_bottom_sheet.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  static const List<DeviceStatus?> _statusTabs = [
    null,
    DeviceStatus.online,
    DeviceStatus.offline,
    DeviceStatus.unknown,
  ];

  final _searchController = TextEditingController();
  DeviceStatus? _currentStatusFilter;
  DeviceSortOption _currentSort = DeviceSortOption.latestUpdated;

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
    if (_currentStatusFilter == status) return;
    setState(() {
      _currentStatusFilter = status;
    });
    context.read<DeviceListCubit>().loadDevices(
      query: _searchController.text,
      statusFilter: status,
      clearFilter: status == null,
    );
  }

  Future<void> _showFilterSheet() async {
    final selected = await DeviceSortBottomSheet.show(
      context,
      initialSort: _currentSort,
    );
    if (selected != null && mounted) {
      setState(() => _currentSort = selected);
      context.read<DeviceListCubit>().loadDevices(sortOption: selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Thiết bị',
        searchHeight: 36.h,
        titleStyle: AppTextStyles.s16w600(color: AppColors.textAppbar),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/device/ic_grid.svg',
            width: 22.r,
            height: 22.r,
            colorFilter: ColorFilter.mode(
              AppColors.textAppbar,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.push(
            '/devices/table',
            extra: context.read<DeviceListCubit>(),
          ),
        ),
        showBackButton: false,
        showBottomBorder: true,
        bottomBorderColor: const Color(0xFFE2E8F0),
        searchController: _searchController,
        searchHintText: 'Tìm kiếm...',
        searchHintStyle: AppTextStyles.s13w400(color: AppColors.textMuted),
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (value) => context.read<DeviceListCubit>().loadDevices(
          query: value,
          statusFilter: _currentStatusFilter,
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/device/ic_loc.svg',
              width: 22.r,
              height: 22.r,
              colorFilter: ColorFilter.mode(
                AppColors.textAppbar,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<DeviceListCubit, DeviceListState>(
            builder: (context, state) {
              final loaded = state is DeviceListLoaded ? state : null;
              final selectedIndex = _statusTabs.indexOf(_currentStatusFilter);
              return AppFilterChipBar(
                selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
                onSelected: (index) => _applyFilter(_statusTabs[index]),
                items: [
                  AppFilterChipItem(label: 'Tất cả', count: loaded?.totalCount),
                  AppFilterChipItem(
                    label: 'Online',
                    count: loaded?.onlineCount,
                  ),
                  AppFilterChipItem(
                    label: 'Offline',
                    count: loaded?.offlineCount,
                  ),
                  AppFilterChipItem(
                    label: 'Không xác định',
                    count: loaded?.unknownCount,
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: BlocConsumer<DeviceListCubit, DeviceListState>(
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
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<DeviceListCubit>().loadDevices(
                          query: _searchController.text,
                          statusFilter: _currentStatusFilter,
                          forceRefresh: true,
                        ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        SizedBox(height: 110.h),
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
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.read<DeviceListCubit>().loadDevices(
                                  query: _searchController.text,
                                  statusFilter: _currentStatusFilter,
                                  forceRefresh: true,
                                ),
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
                        ),
                      ],
                    ),
                  );
                }
                if (state is DeviceListLoaded) {
                  if (state.devices.isEmpty) {
                    final hasFilter =
                        _currentStatusFilter != null ||
                        _searchController.text.trim().isNotEmpty;
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<DeviceListCubit>().loadDevices(
                            query: _searchController.text,
                            statusFilter: _currentStatusFilter,
                            forceRefresh: true,
                          ),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        children: [
                          SizedBox(height: 110.h),
                          Icon(
                            hasFilter
                                ? Icons.search_off_rounded
                                : Icons.devices_other_rounded,
                            size: 52.r,
                            color: const Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            hasFilter
                                ? 'Không tìm thấy thiết bị'
                                : 'Chưa có thiết bị nào',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.s16w600(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          // SizedBox(height: 6.h),
                          // Text(
                          //   hasFilter
                          //       ? 'Thử thay đổi từ khóa tìm kiếm hoặc bỏ bộ lọc trạng thái.'
                          //       : 'Hãy thêm thiết bị mới vào danh sách thiết bị.',
                          //   textAlign: TextAlign.center,
                          //   style: AppTextStyles.s13w400(
                          //     color: AppColors.textSecondary,
                          //   ),
                          // ),
                          // if (hasFilter) ...[
                          //   SizedBox(height: 12.h),
                          //   Center(
                          //     child: TextButton(
                          //       onPressed: () {
                          //         _searchController.clear();
                          //         _applyFilter(null);
                          //       },
                          //       child: const Text('Xóa bộ lọc'),
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<DeviceListCubit>().loadDevices(
                          query: _searchController.text,
                          statusFilter: _currentStatusFilter,
                          forceRefresh: true,
                        ),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                      itemCount: state.devices.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final device = state.devices[index];
                        final routeId = device.imei.isNotEmpty
                            ? device.imei
                            : 'detail';
                        return DeviceListItem(
                          device: device,
                          onTap: () =>
                              context.push('/devices/$routeId', extra: device),
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
