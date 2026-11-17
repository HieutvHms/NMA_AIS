import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/managed_device_entity.dart';
import '../../cubit/device_management_cubit.dart';
import '../../cubit/device_management_state.dart';
import '../../widgets/managed_device_form_dialog.dart';
import '../widgets/managed_device_table_view.dart';

class ManagedDeviceTableScreen extends StatefulWidget {
  const ManagedDeviceTableScreen({super.key});

  @override
  State<ManagedDeviceTableScreen> createState() =>
      _ManagedDeviceTableScreenState();
}

class _ManagedDeviceTableScreenState extends State<ManagedDeviceTableScreen> {
  final _searchController = TextEditingController();

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
    final device = await ManagedDeviceFormDialog.show(context);
    if (device != null && mounted) {
      context.read<DeviceManagementCubit>().createDevice(device);
    }
  }

  void _openEditDialog(ManagedDeviceEntity device) async {
    final updated = await ManagedDeviceFormDialog.show(
      context,
      initialDevice: device,
    );
    if (updated != null && mounted) {
      context.read<DeviceManagementCubit>().updateDevice(updated);
    }
  }

  void _confirmDelete(ManagedDeviceEntity device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Xác nhận xóa thiết bị 4G',
          style: AppTextStyles.titleMediumBlack(),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa trạm "${device.stationName}" (IMEI: ${device.imei}) khỏi hệ thống không?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeviceManagementCubit>().deleteDevice(device);
            },
            child: Text(
              'Xóa',
              style: AppTextStyles.labelLarge2(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Bảng thiết bị 4G',
        backgroundColor: AppColors.background,
        textColor: Color(0xFF1565C0),
        titleStyle: AppTextStyles.titleMediumAppBar(color: Color(0xFF1565C0)),
        searchHintText: 'Tìm kiếm theo tên trạm, IMEI, SIM, cổng...',
        searchController: _searchController,
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (val) =>
            context.read<DeviceManagementCubit>().loadDevices(query: val),
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile/device-management');
          }
        },
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFF1565C0),
            ),
            tooltip: 'Thêm mới thiết bị 4G',
            onPressed: _openAddDialog,
          ),
        ],
      ),
      body: BlocConsumer<DeviceManagementCubit, DeviceManagementState>(
        listener: (context, state) {
          if (state is DeviceManagementLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DeviceManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
                    style: AppTextStyles.bodyMedium(color: Colors.red),
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
            return ManagedDeviceTableView(
              devices: state.devices,
              onEdit: _openEditDialog,
              onDelete: _confirmDelete,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
