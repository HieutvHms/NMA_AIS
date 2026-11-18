import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../app/theme/text_style.dart';
import '../../../../../../core/utils/snackbar_helper.dart';
import '../../../../domain/entities/managed_device_entity.dart';
import '../../../cubit/device_management_cubit.dart';
import '../../../cubit/device_management_state.dart';
import '../../managed_device_form_screen.dart';
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Xác nhận xóa thiết bị 4G', style: AppTextStyles.s16w600()),
        content: Text(
          'Bạn có chắc chắn muốn xóa trạm "${device.stationName}" (IMEI: ${device.imei}) khỏi hệ thống không?',
          style: AppTextStyles.s14w500(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: AppTextStyles.s14w500()),
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
            child: Text('Xóa', style: AppTextStyles.s14w500()),
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
        title: 'Bảng trạm thu AIS',
        backgroundColor: AppColors.background,
        textColor: Color(0xFF1565C0),
        titleStyle: AppTextStyles.s16w600(color: Color(0xFF1565C0)),
        searchHintText: 'Tìm kiếm...',
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
            icon: SvgPicture.asset(
              'assets/icons/device/ic_add.svg',
              width: 24.r,
              height: 24.r,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1565C0),
                BlendMode.srcIn,
              ),
            ),
            onPressed: _openAddDialog,
          ),
        ],
      ),
      body: BlocConsumer<DeviceManagementCubit, DeviceManagementState>(
        listener: (context, state) {
          if (state is DeviceManagementLoaded && state.actionMessage != null) {
            SnackbarHelper.showSuccess(context, message: state.actionMessage!);
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
                  Text(state.message, style: AppTextStyles.s14w500()),
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
