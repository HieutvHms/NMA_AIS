import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../device_list/cubit/device_list_cubit.dart';
import '../../device_list/cubit/device_list_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Bảng thiết bị',
        backgroundColor: AppColors.background,
        textColor: AppColors.textPrimary,
        titleStyle: AppTextStyles.s16w600(),
        searchHintText: 'Tìm kiếm',
        searchController: _searchController,
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (val) =>
            context.read<DeviceListCubit>().loadDevices(query: val),
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/devices');
          }
        },
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.add_circle_outline_rounded,
        //       color: AppColors.primary,
        //     ),
        //     tooltip: 'Thêm mới trạm',
        //     onPressed: _openAddDialog,
        //   ),
        // ],
      ),
      body: BlocBuilder<DeviceListCubit, DeviceListState>(
        builder: (context, state) {
          if (state is DeviceListLoading || state is DeviceListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceListError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.s14w500()),
            );
          }
          if (state is DeviceListLoaded) {
            return DeviceTableView(
              devices: state.devices,
              onSelect: (dev) =>
                  context.push('/devices/${dev.imei}', extra: dev),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
