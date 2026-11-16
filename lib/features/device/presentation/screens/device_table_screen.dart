import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../domain/entities/device_entity.dart';
import '../cubit/device_list_cubit.dart';
import '../cubit/device_list_state.dart';
import '../widgets/device_form_dialog.dart';
import '../widgets/device_table_view.dart';

class DeviceTableScreen extends StatefulWidget {
  const DeviceTableScreen({super.key});

  @override
  State<DeviceTableScreen> createState() => _DeviceTableScreenState();
}

class _DeviceTableScreenState extends State<DeviceTableScreen> {
  final _searchController = TextEditingController();

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

  void _openAddDialog() async {
    final device = await DeviceFormDialog.show(context);
    if (device != null && mounted) {
      context.read<DeviceListCubit>().createDevice(device);
    }
  }

  void _openEditDialog(DeviceEntity device) async {
    final updated = await DeviceFormDialog.show(context, initialDevice: device);
    if (updated != null && mounted) {
      context.read<DeviceListCubit>().updateDevice(updated);
    }
  }

  void _confirmDelete(DeviceEntity device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Xác nhận xóa trạm',
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
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeviceListCubit>().deleteDevice(device.imei);
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp),
          tooltip: 'Quay lại',
          iconSize: 16.r,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/devices');
            }
          },
        ),
        title: Text(
          'Bảng thiết bị AIS',
          style: AppTextStyles.titleMediumAppBar(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Thêm mới trạm',
            onPressed: _openAddDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(6.w),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Tìm kiếm theo tên trạm, IMEI, cổng...',
              backgroundColor: Colors.white,
              borderRadius: 10.r,
              height: 40.h,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              onChanged: (val) =>
                  context.read<DeviceListCubit>().loadDevices(query: val),
            ),
          ),
          // Khối bảng dữ liệu ghim cột hiển thị full màn hình không padding
          Expanded(
            child: BlocBuilder<DeviceListCubit, DeviceListState>(
              builder: (context, state) {
                if (state is DeviceListLoading || state is DeviceListInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DeviceListError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(),
                    ),
                  );
                }
                if (state is DeviceListLoaded) {
                  return DeviceTableView(
                    devices: state.devices,
                    onEdit: _openEditDialog,
                    onDelete: _confirmDelete,
                    onSelect: (dev) =>
                        context.push('/devices/${dev.imei}', extra: dev),
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
