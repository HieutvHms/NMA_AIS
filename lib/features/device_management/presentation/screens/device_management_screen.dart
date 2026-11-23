import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/dia_logs/app_confirm_dialog.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import '../../../../app/commom/tables/ais_device_table_view.dart';
import '../../../../app/commom/tabs/app_tab_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/managed_device_entity.dart';
import '../cubit/device_management_cubit.dart';
import '../cubit/device_management_state.dart';
import '../widgets/managed_device_form_screen.dart';
import '../widgets/device_list/managed_device_list_item.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final _searchController = TextEditingController();
  ManagedDeviceStatus? _currentStatusFilter;
  bool _isTableView = false;

  @override
  void initState() {
    super.initState();
    context.read<DeviceManagementCubit>().loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddDialog() async {
    final device = await ManagedDeviceFormScreen.open(context);
    if (device != null && mounted) {
      context.read<DeviceManagementCubit>().createDevice(device);
    }
  }

  void _openEditDialog(ManagedDeviceEntity device) async {
    final updated = await ManagedDeviceFormScreen.open(
      context,
      initialDevice: device,
    );
    if (updated != null && mounted) {
      context.read<DeviceManagementCubit>().updateDevice(updated);
    }
  }

  void _confirmDelete(ManagedDeviceEntity device) {
    AppConfirmDialog.showDelete(
      context,
      itemName: 'trạm "${device.stationName}"',
      onConfirm: () {
        context.read<DeviceManagementCubit>().deleteDevice(device);
      },
    );
  }

  void _applyFilter(ManagedDeviceStatus? status) {
    setState(() {
      _currentStatusFilter = status;
    });
    context.read<DeviceManagementCubit>().loadDevices(
      query: _searchController.text,
      statusFilter: status,
      clearFilter: status == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textAppbar,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Quản lý trạm thu AIS',
          style: AppTextStyles.s16w600(color: AppColors.textAppbar),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/device/ic_add.svg',
              width: 26.r,
              height: 26.r,
              colorFilter: const ColorFilter.mode(
                AppColors.textAppbar,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _openAddDialog,
          ),
        ],
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Tìm kiếm...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    backgroundColor: Colors.white,
                    borderRadius: 10.r,
                    height: 40.h,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    onChanged: (value) =>
                        context.read<DeviceManagementCubit>().loadDevices(
                          query: value,
                          statusFilter: _currentStatusFilter,
                        ),
                  ),
                ),
                SizedBox(width: 8.w),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  child: InkWell(
                    // onTap: _showFilterSheet,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 40.h,
                      width: 40.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _currentStatusFilter != null
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/device/ic_loc.svg',
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(
                          _currentStatusFilter != null
                              ? AppColors.primary
                              : const Color(0xFF475569),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DefaultTabController(
            length: 2,
            initialIndex: _isTableView ? 1 : 0,
            child: AppTabBar(
              height: 36.h,
              margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              tabs: const [
                AppTabItem(
                  label: 'Danh sách',
                  svgAsset: 'assets/icons/device/ic_list.svg',
                ),
                AppTabItem(
                  label: 'Bảng',
                  svgAsset: 'assets/icons/device/ic_grid.svg',
                ),
              ],
              onTap: (index) {
                final isTable = index == 1;
                if (_isTableView != isTable) {
                  setState(() => _isTableView = isTable);
                }
              },
            ),
          ),
          if (_currentStatusFilter != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
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
                          style: AppTextStyles.s14w500(
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
            child: BlocConsumer<DeviceManagementCubit, DeviceManagementState>(
              listener: (context, state) {
                if (state is DeviceManagementLoaded &&
                    state.actionMessage != null) {
                  SnackbarHelper.showSuccess(
                    context,
                    message: state.actionMessage!,
                  );
                } else if (state is DeviceManagementError) {
                  SnackbarHelper.showError(context, message: state.message);
                }
              },
              builder: (context, state) {
                if (state is DeviceManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DeviceManagementError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          style: AppTextStyles.s14w500(color: Colors.red),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () => context
                              .read<DeviceManagementCubit>()
                              .loadDevices(forceRefresh: true),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is DeviceManagementLoaded) {
                  if (state.devices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.devices_other_rounded,
                            size: 40.r,
                            color: const Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Không tìm thấy trạm thu AIS nào',
                            style: AppTextStyles.s14w500(
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
                  if (_isTableView) {
                    return AisDeviceTableView<ManagedDeviceEntity>(
                      items: state.devices,
                      showActions: true,
                      showStatus: false,
                      showSignal: false,
                      rowBuilder: (item) => AisDeviceTableRow(
                        stationName: item.stationName,
                        imei: item.imei,
                        mmsi: item.mmsi,
                        simSerial: item.simSerial,
                        aisPort: item.aisPort,
                        statusLabel: item.status.label,
                        statusColor: item.status == ManagedDeviceStatus.online
                            ? AppColors.success
                            : AppColors.alertRed,
                        lastMessageTime: item.lastMessageTime,
                        lastAisTime: item.lastAisTime,
                        signalStrength: item.signalStrength,
                        aisModuleType: item.aisModuleType,
                      ),
                      onEdit: _openEditDialog,
                      onDelete: _confirmDelete,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<DeviceManagementCubit>().loadDevices(
                          query: _searchController.text,
                          statusFilter: _currentStatusFilter,
                          forceRefresh: true,
                        ),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 16.h),
                      itemCount: state.devices.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final device = state.devices[index];
                        return ManagedDeviceListItem(
                          device: device,
                          onEdit: () => _openEditDialog(device),
                          onDelete: () => _confirmDelete(device),
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
